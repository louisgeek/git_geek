"""阶段 0（辅助）：开发者写新文案时的入口。

管线的**唯一开发者接触点**是 en 源文件。`new` 命令把"加一条待翻译文案"
变成一个不会出错、且不会破坏历史文件格式的动作。

## 为什么必须"外科手术式"写入

朴素的 `json.loads` → `json.dumps` 往返会重排整个文件：缩进、行尾空格、
注释风格、key 顺序意图全部丢失。对一个已有人工历史的源文件，这会让
git diff 变成全文件噪音，真正的改动被淹没，还可能引入 review 时看不出的
语义漂移（例如刻意保留的行尾空格是 UI 拼接布局的一部分）。

因此本模块只做**行级插入**：定位最后一个 key 的结尾，在其后追加新行，
其余字节原样保留。已有 key 的原值永不被改写。

## 写入安全约束

  1. 绝不改写已有 key 的值 —— 冲突时直接报错，由人决定
  2. 绝不重排已有 key 的顺序
  3. 绝不重排缩进 / 行尾空格 / 注释
  4. 写入前后校验：除新增行外，文件其余部分字节一致
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path

from ..config import Glossary, PipelineConfig, cjk_len
from . import jsonpatch

# key命名：lowerCamelCase 或 snake_case 都接受。
# snake_case 是 ARB / gettext 生态的惯例（如 str_app_version_available），
# 与收件箱解析器（inbox._KEY_RE）保持一致，避免两边规则不同。
_KEY_RE = re.compile(r"^[a-z][a-zA-Z0-9_]*$")
# 常见前缀约定，用于提示一致性（不强制）
_PREFIX_HINTS = {
    "btn": "按钮",
    "err": "错误",
    "empty": "空状态",
    "stat": "统计",
}


@dataclass
class NewEntryResult:
    key: str
    ok: bool
    message: str
    warnings: list[str]


def suggest_key(text: str) -> str:
    """从英文文案猜一个 key（lowerCamelCase）。仅作提示，不强制。"""
    words = re.findall(r"[A-Za-z0-9]+", text)
    if not words:
        return ""
    return words[0].lower() + "".join(w[:1].upper() + w[1:] for w in words[1:])


def validate_key(key: str, existing: set[str]) -> tuple[bool, str, list[str]]:
    """校验 key。返回 (是否合法, 说明, 警告列表)。"""
    warns: list[str] = []
    if not key:
        return False, "key 不能为空", warns
    if key in existing:
        return False, f"key「{key}」已存在（不覆盖已有 key，请换名或手工改值）", warns
    if not _KEY_RE.match(key):
        return False, (
            f"key「{key}」不符合命名规范：应以小写字母开头，只含字母数字与下划线"
        ), warns
    return True, "ok", warns


def analyze_constraints(source: str, glossary: Glossary, max_len: int | None) -> list[str]:
    """分析新文案会命中的术语与长度约束，提前告知开发者。"""
    notes: list[str] = []
    if glossary:
        for t in glossary.match_in(source):
            std_map = "、".join(
                f"{loc}={val}" for loc, val in sorted(t.translations.items())
            )
            notes.append(f"命中术语「{t.term}」：{std_map}")
            if t.forbidden:
                notes.append(f"    全局禁用译法：{'、'.join(t.forbidden)}")
            for loc, vals in sorted(t.forbidden_by_locale.items()):
                notes.append(f"    {loc} 禁用译法：{'、'.join(vals)}")
    if max_len:
        notes.append(f"长度上限：{max_len} 字符（源文当前 {len(source)} 字符）")
    cjk = cjk_len(source)
    if cjk:
        notes.append(f"源文含 {cjk} 个 CJK 字符 —— 源语言应写英文，CJK 通常意味着漏翻")
    if re.search(r"\s{2,}$", source):
        notes.append("源文以多个空格结尾：若为 UI 拼接留白设计，请在 QA allowlist 登记")
    return notes


def add_entry(
    cfg: PipelineConfig,
    key: str,
    source: str,
    glossary: Glossary | None = None,
    description: str | None = None,
    max_length: int | None = None,
    dry_run: bool = False,
    allow_overwrite: bool = False,
) -> NewEntryResult:
    """把一条新文案写入 en 源文件（行级插入，不重排既有内容）。"""
    return _add_to_file(
        target=cfg.source.path,
        fmt=cfg.source.format,
        key=key,
        value=source,
        glossary=glossary,
        description=description,
        max_length=max_length,
        dry_run=dry_run,
        allow_overwrite=allow_overwrite,
        value_label="源文",
    )


def set_translation(
    cfg: PipelineConfig,
    locale: str,
    key: str,
    target: str,
    glossary: Glossary | None = None,
    brief=None,
    dry_run: bool = False,
    allow_overwrite: bool = True,
) -> NewEntryResult:
    """写入一个目标语言的译文（由 ingest 调用）。

    与 add_entry 的区别：
      - 写入**目标语言**文件（按 output.file_map 解析路径），不是 en 源
      - 允许覆盖已有译文（修订场景），会提示旧值；allow_overwrite=False 则拒绝
      - 用目标语言的术语规则校验
    """
    path = cfg.output.target_for(locale)
    if not path.exists():
        return NewEntryResult(
            key, False,
            f"该语言的文件不存在：{path}\n先跑 pipeline run 生成，或修正 output.file_map",
            [],
        )

    warns: list[str] = []
    existing_keys: set[str] = set()
    try:
        from ..adapters.sources import get_adapter

        old = {e.key: e.source for e in get_adapter(cfg.source.format)(path)}
        existing_keys = set(old)
        if key in old and old[key] != target:
            warns.append(f"将覆盖旧译文：{old[key]!r}")
    except Exception:  # noqa: BLE001
        pass

    if not allow_overwrite and key in existing_keys:
        return NewEntryResult(
            key, False,
            f"key「{key}」在 {locale} 已存在；如需覆盖请加 --replace",
            warns,
        )

    return _add_to_file(
        target=path,
        fmt=cfg.source.format,
        key=key,
        value=target,
        glossary=glossary,
        # 译文文件不写 @key 元数据（元数据只在 en 源）
        description=None,
        max_length=(brief.spec_for(locale).max_length if brief else None),
        dry_run=dry_run,
        allow_overwrite=True,
        value_label="译文",
        locale=locale,
    )


def _add_to_file(
    target: Path,
    fmt: str,
    key: str,
    value: str,
    glossary: Glossary | None,
    description: str | None,
    max_length: int | None,
    dry_run: bool,
    allow_overwrite: bool,
    value_label: str,
    locale: str | None = None,
) -> NewEntryResult:
    """行级插入的公共实现：只动新增行，其余字节原样保留。"""
    from ..adapters.sources import get_adapter
    from ..models import placeholder_signature

    src_path = target
    if not src_path.exists():
        return NewEntryResult(key, False, f"文件不存在：{src_path}", [])

    try:
        entries = get_adapter(fmt)(src_path)
    except Exception as e:  # noqa: BLE001
        return NewEntryResult(key, False, f"文件解析失败：{e}", [])
    existing = {e.key for e in entries}

    if not allow_overwrite:
        ok, msg, warns = validate_key(key, existing)
        if not ok:
            return NewEntryResult(key, False, msg, warns)
    else:
        warns = []

    if not value.strip():
        return NewEntryResult(key, False, f"{value_label}为空", warns)

    # 术语校验：源文侧（en）用源文比对；译文侧用译文反查
    if glossary is not None:
        if locale is None:
            warns.extend(analyze_constraints(value, glossary, max_length))
        else:
            for bad, term, is_forbidden in glossary.lookup_target(value, locale):
                if is_forbidden:
                    warns.append(f"⚠ 命中该语言禁用译法「{bad}」（术语：{term}）")
    if max_length:
        from ..config import cjk_len

        n = cjk_len(value)
        if n > max_length:
            warns.append(f"⚠ CJK 长度 {n} 超过上限 {max_length}")

    if dry_run:
        return NewEntryResult(key, True, "校验通过（dry-run，未写入）", warns)

    if fmt in ("arb", "json"):
        # 译文文件不写 @key 元数据（元数据只在 en 源）
        meta = (
            _build_arb_meta(value, description, max_length, placeholder_signature)
            if (fmt == "arb" and locale is None)
            else None
        )
        # 统一走 jsonpatch.upsert：它处理了「插入点跳过 @key 嵌套块」
        # 「统一规整逗号」「写前双重校验」等细节 —— 是唯一经 13 场景回归的实现。
        # 先 dry-run 校验（不落盘），通过后再实际写入。
        try:
            jsonpatch.upsert(src_path, {key: value},
                             meta={key: meta} if meta else None, dry_run=True)
            jsonpatch.upsert(src_path, {key: value},
                             meta={key: meta} if meta else None)
        except ValueError as e:
            return NewEntryResult(key, False, str(e), warns)
        verb = "已更新" if key in existing else "已写入"
        return NewEntryResult(key, True, f"{verb} {src_path.name}：{key}", warns)
    elif fmt == "csv":
        text, bom = _insert_csv_row(src_path, key, value)
    else:
        return NewEntryResult(
            key, False,
            f"格式 {fmt} 暂不支持该命令，请手工编辑 {src_path}",
            warns,
        )

    ok2, diff_note = _write_preserving(src_path, text, bom, allow_replace=allow_overwrite)
    if not ok2:
        return NewEntryResult(key, False, diff_note, warns)

    verb = "已更新" if (allow_overwrite and key in existing) else "已写入"
    return NewEntryResult(key, True, f"{verb} {src_path.name}：{key}", warns)


def _build_arb_meta(
    source: str, description: str | None, max_length: int | None, ph_sig
) -> dict | None:
    meta: dict[str, object] = {}
    phs = ph_sig(source)
    if phs:
        meta["placeholders"] = {p: {"type": "String"} for p in phs}
    if description:
        meta["description"] = description
    if max_length:
        meta["maxLength"] = max_length
    return meta or None


# _read_text / _write_text / _detect_base_indent 已统一到 jsonpatch
# （原先此处有一份重复实现，与产物侧行为不一致的风险很高）
_read_text = jsonpatch.read_text
_write_text = jsonpatch.write_text
_detect_base_indent = jsonpatch.detect_base_indent


def _unit_indent(base: str, sample_text: str) -> str:
    """推断一级缩进宽度。

    只考察「缩进比 base 更深、且该行是结构行（以 " 开头）」的情况；
    值里含空格的行不参与判断，否则会被 `"    有多余空格    "` 误导。
    """
    if base:
        pat = re.compile(r"^" + re.escape(base) + r"([ \t]+)\"")
        for line in sample_text.splitlines():
            m = pat.match(line)
            if m:
                return m.group(1)
    return base if base else "  "


def _render_entry(key: str, value: str | dict, indent: str, unit: str) -> list[str]:
    """把一条 key 渲染成若干行（不含行尾换行符）。

    自己逐行渲染而非「json.dumps(indent=2) 后逐行加逗号」——
    后者会把嵌套对象的开括号行也挂上逗号，产出非法 JSON。

    逗号规则（JSON 语法）：
      - 标量行 / 闭合行：若不是该对象的最后一项，补逗号
      - 开括号行：**永不**带逗号
    """
    if isinstance(value, str):
        return [f'{indent}"{key}": {json.dumps(value, ensure_ascii=False)}']

    lines: list[str] = [f'{indent}"{key}": {{']
    items = list(value.items())
    for i, (k, v) in enumerate(items):
        last = i == len(items) - 1
        if isinstance(v, dict):
            sub = _render_entry(k, v, indent + unit, unit)
            # 递归内部已处理逗号，仅在非末项时给闭合行补逗号
            if not last and not sub[-1].rstrip().endswith(","):
                sub[-1] = sub[-1] + ","
            lines.extend(sub)
        else:
            comma = "" if last else ","
            lines.append(
                f'{indent}{unit}"{k}": {json.dumps(v, ensure_ascii=False)}{comma}'
            )
    lines.append(f"{indent}}}")
    return lines


def _insert_csv_row(path: Path, key: str, source: str) -> tuple[str, bool]:
    """CSV 追加一行（行式格式，追加是安全的）。"""
    import csv as _csv
    import io

    if path.exists() and path.stat().st_size:
        text, bom = _read_text(path)
        buf = io.StringIO()
        _csv.writer(buf, lineterminator="\n").writerow([key, source])
        if not text.endswith(("\n", "\r")):
            text += "\r\n" if "\r\n" in text else "\n"
        return text + buf.getvalue(), bom

    buf = io.StringIO()
    _csv.writer(buf, lineterminator="\n").writerow([key, source])
    return "key,source\n" + buf.getvalue(), False


def _write_preserving(
    path: Path, new_text: str, bom: bool, allow_replace: bool = False
) -> tuple[bool, str]:
    """写入前双重校验，通过后才落盘。

    1. 新内容必须是合法 JSON（防止行级渲染出错）
    2. 原有每一行都必须仍存在（防止误删历史内容）
       —— allow_replace=True 时允许「同一个key 旧值行」被替换掉
    """
    # 校验 1：JSON 合法性
    try:
        json.loads(new_text.replace("\ufeff", ""))
    except json.JSONDecodeError as e:
        return False, (
            f"写入校验失败：新内容不是合法 JSON（{e.msg}，第 {e.lineno} 行），已放弃写入"
        )

    old_text, _ = _read_text(path)
    if new_text == old_text:
        return True, ""

    # 校验 2：原有行必须逐行保留
    old_lines = old_text.replace("\r\n", "\n").splitlines()
    new_lines = new_text.replace("\r\n", "\n").splitlines()

    def norm(lines: list[str]) -> list[str]:
        return [l.rstrip().rstrip(",").rstrip() for l in lines]

    new_norm = set(norm(new_lines))
    old_norm = norm(old_lines)

    missing = [l for l in old_norm if l not in new_norm]
    if missing and allow_replace:
        # 允许「同 key 的旧值行被替换」：该行的 key 在新内容里仍存在，
        # 且 key 出现次数不变 ⇒ 是值被改，不是内容丢失。
        def keys_of(lines: list[str]) -> dict[str, int]:
            out: dict[str, int] = {}
            for l in lines:
                m = re.match(r'^\s*"([^"]+)"\s*:', l)
                if m:
                    out[m.group(1)] = out.get(m.group(1), 0) + 1
            return out

        old_k, new_k = keys_of(old_lines), keys_of(new_lines)
        truly_missing = []
        for l in missing:
            m = re.match(r'^\s*"([^"]+)"\s*:', l)
            if m and old_k.get(m.group(1)) == new_k.get(m.group(1)):
                continue  # 同 key 数量一致 → 视为值被替换
            truly_missing.append(l)
        missing = truly_missing

    if missing:
        return False, (
            f"写入校验失败：新内容丢失了 {len(missing)} 行原有内容，已放弃写入"
        )

    _write_text(path, new_text, bom)
    return True, ""