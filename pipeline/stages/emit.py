"""阶段 7：产物输出 + TM 入库 + 报告。

Fallback 策略在此落地：某语言缺译文时回落源语言（默认 en），
不让一门语言的缺失卡住整个发布。
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

from ..models import Entry, QAIssue, Translation
from . import jsonpatch
from .diff import EntryFingerprint
from .tm import TranslationMemory


def _output_order(
    path: Path, entries: list[Entry], translations: dict[str, str]
) -> list[str]:
    """输出顺序：优先沿用目标文件原有 key 顺序，其余按源文件顺序追加。

    为什么必须这样做：译文文件的 key 顺序往往与源文件**不一致**（该项目
    126 个 key 里只有 3 个位置相同）。若按源文件顺序输出，每次写入都会把
    译文文件整体重排，git diff 变成"全文件挪动"，真正要审的那一行被淹没，
    而且 review 时看不出任何内容变化 —— 这比脏 diff 更危险。
    """
    order: list[str] = []
    if path.exists():
        try:
            data = json.loads(path.read_text(encoding="utf-8-sig"))
            order = [
                k for k in data
                if not k.startswith("@") and k != "@@locale" and k in translations
            ]
        except Exception:  # noqa: BLE001  解析失败则退回源文件顺序
            order = []
    seen = set(order)
    for e in entries:
        if e.key not in seen and e.key in translations:
            order.append(e.key)
            seen.add(e.key)
    return order


def write_arb(
    path: Path,
    entries: list[Entry],
    translations: dict[str, str],
    locale: str,
    include_meta: bool = False,
    strict: bool = True,
    arb_locale: str | None = None,
    preserve_order: bool = True,
) -> None:
    """按 ARB 格式写出。

    ## 顺序策略（重要）

    `preserve_order=True`（默认）时，**沿用目标文件原有的 key 顺序**，
    新 key 追加到末尾。若按 `entries`（源文件顺序）输出，会把译文文件
    整体重排 —— 实测该项目 126 个 key 里只有 3 个位置与源文件一致，
    也就是说一次写入就会让 git diff 变成"全文件挪动"，真正要审的那一行
    被淹没，且 review 时看不出任何内容变化。

    这类"内容没变、位置变了"的 diff 比脏 diff 更危险：它掩盖了真正的改动。

    ## 其他约束

    `entries` 必须是**完整的**源条目列表——strict=True 会校验，
    传入子集会导致大量译文被静默丢弃。

    `arb_locale` 是写进 `@@locale` 的值，**不一定是 BCP-47 标签**：
    Flutter 的 arb 用语言桶码（`zh` / `zh_Hant` / `zh_Hant_HK`），
    写成 `zh-Hant-TW` 会让 `gen_l10n` 找不到该文件并静默忽略。
    """
    path.parent.mkdir(parents=True, exist_ok=True)

    entry_keys = {e.key for e in entries}
    if strict:
        extra = set(translations) - entry_keys
        if extra:
            raise ValueError(
                f"write_arb 收到 {len(extra)} 个不在 entries 里的 key"
                f"（如 {sorted(extra)[:3]}）。\n"
                f"  entries 必须是完整源条目列表，否则产物会丢失其余译文。\n"
                f"  若只想更新部分 key，请合并后传入完整 entries。"
            )

    # 输出顺序：优先沿用目标文件原有顺序，其余按源文件顺序追加
    order = (
        _output_order(path, entries, translations)
        if preserve_order
        else [e.key for e in entries if e.key in translations]
    )

    by_key = {e.key: e for e in entries}

    # ---- 行级写入：只动该动的行 ----
    # 不做 `json.dumps` 全量重写 —— 那会重排、重排缩进、抹掉行尾空格，
    # 让"内容没变"的既有 key 也产生 diff。见 stages/jsonpatch.py 的说明。
    updates = {k: v for k, v in translations.items() if isinstance(v, str)}
    meta_map: dict[str, dict] = {}
    if include_meta:
        for key in updates:
            e = by_key.get(key)
            if e is None:
                continue
            meta: dict[str, object] = {}
            if e.placeholders:
                meta["placeholders"] = {p: {"type": "String"} for p in e.placeholders}
            if e.description:
                meta["description"] = e.description
            if e.max_length:
                meta["maxLength"] = e.max_length
            if meta:
                meta_map[key] = meta

    # 只写**有译文**的 key；源里已删的 key 不在此列，因此不会误删产物里的条目
    jsonpatch.upsert(
        path,
        updates,
        meta=meta_map or None,
        arb_locale=arb_locale or locale,
    )


def write_json(
    path: Path, entries: list[Entry], translations: dict[str, str], locale: str
) -> None:
    """写嵌套 JSON 产物（点号路径建树）。

    同样走行级 upsert —— 与 write_arb 保持一致，产品文件不做全量重写。
    """
    nested: dict[str, object] = {}
    updates: dict[str, str] = {}
    for e in entries:
        target = translations.get(e.key)
        if target is None:
            continue
        parts = e.key.split(".")
        node = nested
        for p in parts[:-1]:
            node = node.setdefault(p, {})  # type: ignore[assignment]
        node[parts[-1]] = target
        updates[e.key] = target
    jsonpatch.upsert(path, updates)


def write_key_value(
    path: Path, entries: list[Entry], translations: dict[str, str], locale: str
) -> None:
    """写 key=value 产物。**行级追加**：已有行原地更新/保留，新 key 追加到末尾。"""
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        text, bom = jsonpatch.read_text(path)
    else:
        text, bom = "", False
    lines = text.splitlines(keepends=True)
    nl = "\r\n" if "\r\n" in text else "\n"

    # key → 行号
    idx: dict[str, int] = {}
    for i, l in enumerate(lines):
        if "=" in l and not l.strip().startswith("#"):
            k = l.split("=", 1)[0].strip()
            if k and k not in idx:
                idx[k] = i

    changed = 0
    # 按 translations 遍历（不依赖 entries 的 key 对应关系）
    had_trailing_nl = bool(lines) and lines[-1].endswith(("\n", "\r"))
    for key, target in translations.items():
        if not isinstance(target, str):
            continue
        if key in idx:
            # 就地替换：沿用该行原有的换行符（保持 CRLF/无尾换行等）
            old = lines[idx[key]]
            tail = old[len(old.rstrip("\r\n")):]
            new_line = f"{key}={target}{tail}"
            if old != new_line:
                lines[idx[key]] = new_line
                changed += 1
        else:
            # 新 key 追加到末尾：末行若无换行符，先给它补上再接新行
            if lines and not had_trailing_nl:
                lines[-1] = lines[-1].rstrip("\r\n") + nl
            lines.append(f"{key}={target}{nl}")
            idx[key] = len(lines) - 1
            changed += 1

    if changed:
        jsonpatch.write_text(path, "".join(lines), bom)


def apply_fallback(
    entries: list[Entry],
    translations: list[Translation],
    fallback_locale: str,
) -> tuple[list[Translation], int]:
    """缺失译文回落源语言。返回补齐后的列表与回落条数。"""
    have = {tr.key for tr in translations}
    filled = list(translations)
    n = 0
    for e in entries:
        if e.key not in have:
            filled.append(
                Translation(
                    key=e.key,
                    target=e.source,
                    locale=translations[0].locale if translations else fallback_locale,
                    origin="fallback_en",
                    note=f"回落 {fallback_locale}",
                )
            )
            n += 1
    return filled, n


def commit_tm(
    tm: TranslationMemory,
    entries: list[Entry],
    translations: list[Translation],
    approved: bool = False,
) -> int:
    """把译文写入 TM。默认不标记 approved —— 人工审核后才置真。"""
    n = 0
    src = {e.key: e.source for e in entries}
    for tr in translations:
        if tr.origin == "fallback_en":
            continue  # 回落文案不入库，避免污染记忆库
        tm.remember(
            source=src.get(tr.key, ""),
            locale=tr.locale,
            target=tr.target,
            origin=tr.origin,
            approved=approved,
        )
        n += 1
    tm.save()
    return n


def write_baseline(
    path: Path,
    entries: list[Entry],
    translations: list[Translation],
    locale: str,
    glossary_version: str,
    brief_version: str,
) -> None:
    """写增量基线：指纹 → 译文映射，供下次 diff 使用。"""
    path.parent.mkdir(parents=True, exist_ok=True)
    src = {e.key: e for e in entries}
    records = []
    for tr in translations:
        e = src.get(tr.key)
        if e is None:
            continue
        fp = EntryFingerprint(
            source_hash=e.source_hash,
            glossary_version=glossary_version,
            brief_version=brief_version,
            locale=locale,
        )
        records.append(
            {
                "fingerprint": fp.as_str(),
                "key": tr.key,
                "source_hash": e.source_hash,
                "locale": tr.locale,
                "target": tr.target,
                "origin": tr.origin,
            }
        )
    path.write_text(
        json.dumps({"locale": locale, "records": records}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def load_baseline(path: Path, locale: str) -> dict[str, dict]:
    """读基线，返回 {fingerprint: record}。"""
    if not path.exists():
        return {}
    data = json.loads(path.read_text(encoding="utf-8"))
    if data.get("locale") != locale:
        return {}
    return {r["fingerprint"]: r for r in data.get("records", [])}


def write_report(
    path: Path,
    report,
    issues: list[QAIssue],
    locales: list[str],
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "locales": locales,
        "stats": report.as_dict(),
        "issues": [
            {
                "rule": i.rule,
                "locale": i.locale,
                "key": i.key,
                "message": i.message,
                "blocking": i.blocking,
                "hint": i.hint,
            }
            for i in issues
        ],
    }
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )