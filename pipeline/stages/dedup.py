"""去重：把待翻译项匹配到 en 里已存在的等价 key。

## 为什么需要

`inbox` 里开发者可能写了一条文案，而 en 源里**已经有等价的了**——
措辞不同但语义相同（"Refresh cache" vs "Refresh remote cache"、
"Close" vs "Dismiss"）。若不管，产物里会出现两条几乎一样的 key，
术语表与 TM 都会分裂，跨批次一致性无从保证。

## 匹配分四级（从严到宽）

| 级别 | 判据 | 动作 |
|---|---|---|
| exact | 源文完全相同（归一化后） | 直接复用该 key，丢弃待翻译项 |
| normalized | 去标点/空白/大小写后相同 | 同上 |
| fuzzy | 相似度 ≥ 阈值（默认 0.85） | **需人工确认**，不自动合|
| none | 无匹配 | 正常新增 |

精确/归一化命中才自动合并 —— 这两级不会有歧义。
模糊匹配只提示不自动合，避免"看起来像但语义不同"被错误合并。

## 代码引用改写

复用已有 key 时，必须把代码里对新 key 的引用改指向旧 key。
这需要**精确的引用识别**：

- `t.someKey` —— 但 `t` 也可能是普通 Dart 变量（`t.name`、`t.split`）
- `t(AppLang.zh).someKey` —— data 层的形式

因此策略是**白名单驱动**：只有当候选名字确实是 en 里存在的 key 时才改写。
这样 `t.name` 天然被排除，不需要维护"哪些成员名不是 key"的脆弱黑名单。
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from difflib import SequenceMatcher
from pathlib import Path

from .inbox import InboxItem
from ..models import Entry, text_hash

# 模糊匹配阈值。
#
# 实测（SequenceMatcher，短 UI 文案）：
#   "Refresh all caches" vs "Refresh all"  → 0.759   ← 真重复
#   "Delete all tags"    vs "Delete all"   → 0.800   ← 真重复
#   "Refresh remote cache" vs "Refresh all"→ 0.581   ← 语义相近但不同
#   "Completely unrelated string"           → 0.158   ← 无关
#
# 取 0.72：高于真重复的常见下限 0.75 略留余量，且与无关文本（0.16）拉开
# 5 倍以上距离。模糊命中**只提示不自动合**，所以宁可多提示也不漏。
DEFAULT_FUZZY_THRESHOLD = 0.72

_PUNCT_RE = re.compile(r"[^\w\u4e00-\u9fff]+")
_WS_RE = re.compile(r"\s+")


def normalize(text: str) -> str:
    t = (text or "").lower()
    t = _PUNCT_RE.sub(" ", t)
    return _WS_RE.sub(" ", t).strip()


def similarity(a: str, b: str) -> float:
    na, nb = normalize(a), normalize(b)
    if not na or not nb:
        return 0.0
    if na == nb:
        return 1.0
    return SequenceMatcher(None, na, nb).ratio()


@dataclass
class DupMatch:
    """一条待翻译项的匹配结果。"""

    item_key: str
    item_text: str
    existing_key: str | None = None
    existing_text: str = ""
    level: str = "none"          # exact | normalized | fuzzy | none
    score: float = 0.0
    needs_review: bool = False    # 模糊匹配需人工确认

    @property
    def is_dup(self) -> bool:
        """是否可自动合并（精确/归一化）。"""
        return self.level in ("exact", "normalized") and self.existing_key is not None

    @property
    def is_candidate(self) -> bool:
        """是否发现了相似项（含需确认的）。"""
        return self.level != "none" and self.existing_key is not None


@dataclass
class DedupReport:
    matches: list[DupMatch] = field(default_factory=list)
    unique: list[InboxItem] = field(default_factory=list)

    @property
    def dups(self) -> list[DupMatch]:
        return [m for m in self.matches if m.is_dup]

    @property
    def candidates(self) -> list[DupMatch]:
        return [m for m in self.matches if m.is_candidate and m.needs_review]


def find_matches(
    items: list[InboxItem],
    entries: list[Entry],
    fuzzy_threshold: float = DEFAULT_FUZZY_THRESHOLD,
) -> DedupReport:
    """把每条待翻译项匹配到 en 已有的 key。"""
    rep = DedupReport()
    # 源文完全相同的：后写的让位给先写的（先来先用）
    by_exact: dict[str, Entry] = {}
    by_norm: dict[str, Entry] = {}
    for e in entries:
        by_exact.setdefault(e.source.strip(), e)
        by_norm.setdefault(normalize(e.source), e)

    # 收件箱内部也要去重（同批里两条相同）
    seen_in_batch: dict[str, str] = {}

    for it in items:
        norm = normalize(it.text)
        prev = seen_in_batch.get(norm)
        if prev is not None:
            rep.matches.append(
                DupMatch(it.key, it.text, prev, prev, "exact", 1.0)
            )
            continue

        hit = by_exact.get(it.text.strip())
        if hit is not None:
            rep.matches.append(
                DupMatch(it.key, it.text, hit.key, hit.source, "exact", 1.0)
            )
            seen_in_batch[norm] = hit.key
            continue

        hit = by_norm.get(norm)
        if hit is not None:
            rep.matches.append(
                DupMatch(it.key, it.text, hit.key, hit.source, "normalized", 1.0)
            )
            seen_in_batch[norm] = hit.key
            continue

        # 模糊：只提示，不自动合
        best: tuple[float, Entry] | None = None
        for e in entries:
            s = similarity(it.text, e.source)
            if best is None or s > best[0]:
                best = (s, e)
        if best and best[0] >= fuzzy_threshold:
            rep.matches.append(
                DupMatch(
                    it.key, it.text, best[1].key, best[1].source,
                    "fuzzy", round(best[0], 4), needs_review=True,
                )
            )
        else:
            rep.matches.append(DupMatch(it.key, it.text, level="none"))
            seen_in_batch[norm] = it.key
            rep.unique.append(it)

    return rep


# ---------------- 代码引用改写 ----------------

_GEN_MARKERS = ("l10n/gen", "app_localizations", "l10n/generated")

# 两种引用形态：t.key  与  ).key /  t(...).key
_REF_PATTERNS = [
    re.compile(r"\bt\.(?P<key>[A-Za-z][A-Za-z0-9]*)"),
    re.compile(r"\)\.(?P<key>[A-Za-z][A-Za-z0-9]*)"),
]


def is_generated(path: Path) -> bool:
    s = str(path).replace("\\", "/")
    return any(m in s for m in _GEN_MARKERS)


@dataclass
class RefRewrite:
    """一次引用改写的记录。"""

    file: str
    line_no: int
    old: str
    new: str
    count: int = 1


def rewrite_references(
    roots: list[Path],
    old_key: str,
    new_key: str,
    valid_keys: set[str],
    dry_run: bool = True,
) -> list[RefRewrite]:
    """把代码里 `t.oldKey` 改写为 `t.newKey`。

    安全策略：**白名单驱动**。只有当捕获到的名字确实是 en 源里存在的 key
    时才可能改写，因此 `t.name` / `t.split` / `t.length` 这类 Dart 成员访问
    天然被排除 —— 不需要维护脆弱的黑名单。

    跳过生成目录（`l10n/gen`），那里的 key 由 gen_l10n 生成。
    """
    if old_key == new_key:
        return []

    # 只在 new_key 确实是合法 key 时才允许改写
    if new_key not in valid_keys:
        return []

    results: list[RefRewrite] = []
    for root in roots:
        files = [root] if root.is_file() else list(root.rglob("*.dart"))
        for f in files:
            if is_generated(f):
                continue
            try:
                text = f.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                continue
            if old_key not in text:
                continue

            new_text = text
            hits = 0
            for pat in _REF_PATTERNS:
                def _sub(m: re.Match) -> str:
                    nonlocal hits
                    if m.group("key") == old_key:
                        hits += 1
                        return m.group(0).replace(old_key, new_key)
                    return m.group(0)

                new_text = pat.sub(_sub, new_text)

            if hits == 0 or new_text == text:
                continue
            for i, (a, b) in enumerate(
                zip(text.splitlines(), new_text.splitlines()), start=1
            ):
                if a != b:
                    results.append(
                        RefRewrite(str(f), i, a.strip()[:70], b.strip()[:70], hits)
                    )
            if not dry_run:
                f.write_text(new_text, encoding="utf-8")
    return results


def collect_valid_keys(entries: list[Entry]) -> set[str]:
    return {e.key for e in entries}
