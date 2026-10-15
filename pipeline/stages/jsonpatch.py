"""JSON/ARB 文件的**行级**增改原语。

## 为什么不用 `json.loads` → `json.dumps` 往返

往返会重排 key、重排缩进、抹掉行尾空格、规范化换行符。对一个已有人工历史的
文件，这会让 git diff 变成全文件噪音，还会静默丢掉那些"看起来没用但其实是
刻意的"格式（例如 UI 拼接依赖的行尾空格）。

本项目两次实测踩坑：
  1. `write_arb` 按源文件顺序输出 → 译文文件整体重排（126 个 key 里只有
     3 个位置与源文件一致）。内容没变位置全变，review 时看不出实质改动。
  2. `write_arb` 收到子集 entries → 静默丢掉 126 条译文。

所以原则是：**只动该动的行**。
- 已有 key 改值 → 只替换那一行
- 新增 key → 在末尾追加一行
- 其他字节（BOM、换行符、缩进、行尾空格、key 顺序）全部原样保留

## 实现要点：先算全文，再校验，最后一次写

不做"插入多处 + 逐个补逗号"这种增量操作 —— 那样行号会在插入时漂移、
补逗号也会补错位置（第一版就栽在这里，连续两次产出非法 JSON）。

流程是：

  1. 把文件读成"行 + 行归属"的视图
  2. 在视图上做全部修改（改值 / 删除 / 追加 / 头部）
  3. **一次性**给最后一个 key 行去掉尾逗号（JSON 不允许）
  4. 拼成全文，做双重校验（合法 JSON + 原有行一条不少）
  5. 一次写入

key 顺序**永不改变** —— 重排会产生"内容没变位置全变"的 diff。
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from pathlib import Path

# 顶层 key 行：  "key": value      （value 允许含转义引号）
_TOP_RE = re.compile(r'^(?P<ind>[ \t]*)"(?P<key>[^"]+)"\s*:\s*(?P<val>.*)$')
_STRUCT = ("{", "}", "},", "{,")


@dataclass
class Doc:
    """文档的行视图。行的顺序 == 文件里的顺序。"""

    lines: list[str] = field(default_factory=list)
    keys: list[str | None] = field(default_factory=list)   # 每行的顶层 key（None=非 key 行）
    base: str = ""
    nl: str = "\n"
    bom: bool = False

    # ---------- 加载 ----------

    @classmethod
    def load(cls, path: Path) -> "Doc":
        raw = path.read_bytes() if path.exists() else b""
        bom = raw.startswith(b"\xef\xbb\xbf")
        return cls.from_text(raw.decode("utf-8-sig"), None, None, bom)

    @classmethod
    def from_text(
        cls, text: str, base: str | None = None, nl: str | None = None,
        bom: bool = False,
    ) -> "Doc":
        base = detect_base_indent(text) if base is None else base
        nl = ("\r\n" if "\r\n" in text else "\n") if nl is None else nl
        lines: list[str] = []
        keys: list[str | None] = []
        for l in text.splitlines(keepends=True):
            s = l.strip()
            if s in _STRUCT:
                lines.append(l)
                keys.append(None)
                continue
            m = _TOP_RE.match(l)
            if m and m.group("ind") == base:
                lines.append(l)
                keys.append(m.group("key"))
            else:
                lines.append(l)
                keys.append(None)
        return cls(lines=lines, keys=keys, base=base, nl=nl, bom=bom)

    # ---------- 查询 ----------

    def value_of(self, key: str) -> str | None:
        """取某个顶层 key 的当前值（不含引号与尾逗号）。"""
        for l, k in zip(self.lines, self.keys):
            if k == key:
                return _strip_value(l)
        return None

    def has(self, key: str) -> bool:
        return any(k == key for k in self.keys)

    def close_index(self) -> int:
        """最后一个 `}` 所在行号（0-based）；没有则返回行数。"""
        for i in range(len(self.lines) - 1, -1, -1):
            if self.lines[i].strip().startswith("}"):
                return i
        return len(self.lines)

    def render(self) -> str:
        return "".join(self.lines)


def _strip_value(line: str) -> str:
    """取出该行 key 对应的值（去掉首尾引号、尾逗号）。"""
    m = _TOP_RE.match(line)
    if not m:
        return ""
    v = m.group("val").rstrip().rstrip(",").strip()
    return v[1:-1] if len(v) >= 2 and v[0] == '"' else v


def read_text(path: Path) -> tuple[str, bool]:
    """读文件，返回 (文本, 是否带 BOM)。二进制读，保留原始 CRLF/LF。"""
    raw = path.read_bytes() if path.exists() else b""
    bom = raw.startswith(b"\xef\xbb\xbf")
    return raw.decode("utf-8-sig"), bom


def write_text(path: Path, text: str, bom: bool = False) -> None:
    """二进制写，禁用换行转换，确保除目标行外字节不变。"""
    path.parent.mkdir(parents=True, exist_ok=True)
    data = text.encode("utf-8")
    if bom:
        data = b"\xef\xbb\xbf" + data
    path.write_bytes(data)


def detect_base_indent(text: str) -> str:
    """顶层 key 的缩进基准（取最少缩进层级）。文件可能整体缩进。"""
    min_indent = None
    for line in text.splitlines():
        m = _TOP_RE.match(line)
        if m:
            ind = m.group("ind")
            if min_indent is None or len(ind) < len(min_indent):
                min_indent = ind
    return min_indent or ""


def _has_comma(line: str) -> bool:
    return line.rstrip("\r\n").rstrip().endswith(",")


def _strip_trailing_comma(line: str) -> str:
    if not _has_comma(line):
        return line
    nl = "\r\n" if line.endswith("\r\n") else ("\n" if line.endswith("\n") else "")
    return line.rstrip("\r\n").rstrip()[:-1] + nl


def _add_trailing_comma(line: str) -> str:
    if _has_comma(line):
        return line
    nl = "\r\n" if line.endswith("\r\n") else ("\n" if line.endswith("\n") else "")
    return line.rstrip("\r\n").rstrip() + "," + nl


def _block_close_index(lines: list[str], start: int) -> int:
    """从 `start` 行的 `{` 起，找到与之配对的 `}` 行号。"""
    depth = 1
    for i in range(start + 1, len(lines)):
        t = lines[i].strip()
        if t.endswith("{"):
            depth += 1
        elif t.startswith("}"):
            depth -= 1
            if depth == 0:
                return i
    return start


def _mk(key: str, value: str, base: str, nl: str, comma: bool = True) -> str:
    return f'{base}"{key}": {json.dumps(value, ensure_ascii=False)}{"," if comma else ""}{nl}'


def _render_meta(key: str, value: dict, base: str, nl: str, comma: bool = True) -> list[str]:
    """渲染 @key 元数据。

    三类行的区别：
      - 开括号行 `"k": {`   → 无逗号，但**必须有行尾换行符**
      - 标量行`"x": 1`   → 按是否末项决定逗号
      - 闭合行 `}`           → 按是否末项决定逗号
    （早期版本给开括号行漏了 nl，导致整块挤成一行。）
    """
    lines: list[str] = [f'{base}"{key}": {{{nl}']
    items = list(value.items())
    for i, (k, v) in enumerate(items):
        last = i == len(items) - 1
        if isinstance(v, dict):
            sub = _render_meta(k, v, base + "  ", nl, comma=not last)
            lines.extend(sub)
        else:
            c = "" if last else ","
            lines.append(f'{base}  "{k}": {json.dumps(v, ensure_ascii=False)}{c}{nl}')
    lines.append(f"{base}}}{',' if comma else ''}{nl}")
    return lines


@dataclass
class Result:
    updated: int = 0
    added: int = 0
    removed: int = 0
    meta_added: int = 0

    def as_dict(self) -> dict[str, int]:
        return {
            "updated": self.updated,
            "added": self.added,
            "removed": self.removed,
            "meta_added": self.meta_added,
        }


def upsert(
    path: Path,
    updates: dict[str, str],
    removes: set[str] | None = None,
    meta: dict[str, dict] | None = None,
    arb_locale: str | None = None,
    dry_run: bool = False,
) -> Result:
    """行级增改 JSON/ARB。只动该动的行，其余字节原样保留。

    updates     key → 新值。已存在则替换那一行；不存在则追加到末尾。
    removes     要删除的 key。
    meta        key → 元数据字典（写为 `@key`）。
    arb_locale  写进 `@@locale` 的值（语言桶码，如 zh_Hant）。
    dry_run     只统计不落盘。
    """
    removes = removes or set()
    doc = Doc.load(path)
    base, nl = doc.base, doc.nl
    res = Result()
    existed = path.exists()
    original = doc.render() if existed else ""

    lines = list(doc.lines)
    keys = list(doc.keys)

    # ---- 1) 就地改值 / 删除 ----
    for i, (l, k) in enumerate(zip(lines, keys)):
        if k is None:
            continue
        if k in removes:
            lines[i] = ""
            keys[i] = None
            res.removed += 1
        elif k in updates and _strip_value(l) != updates[k]:
            lines[i] = _mk(k, updates[k], base, nl, _has_comma(l))
            res.updated += 1

    # ---- 2) 追加新 key（只追加，不改动任何既有行）----
    pending: list[str] = []
    pending_keys: list[str | None] = []
    for k, v in updates.items():
        if any(kk == k for kk in keys):
            continue
        pending.append(_mk(k, v, base, nl, comma=True))
        pending_keys.append(k)
        res.added += 1
    for k, m in (meta or {}).items():
        rendered = _render_meta(f"@{k}", m, base, nl, comma=True)
        pending.extend(rendered)
        pending_keys.extend([None] * len(rendered))
        res.meta_added += 1

    if pending:
        # 单行空对象 "{}" / "{ }"：先展开成多行，否则没法按行插入
        if len(lines) == 1 and lines[0].strip().startswith("{") and lines[0].strip().endswith("}"):
            ind = base or "  "
            lines = ["{" + nl, "}" + nl]
            keys = [None, None]
            at = 1
        else:
            # 插入点 = 最后一个顶层 key（含其嵌套块）之后。
            # 顶层 key 可能跨多行（@key 元数据），要跳过整个块而不是停在 `}` 前，
            # 否则新条目会插到嵌套块内部，把 @key 的结构破坏掉。
            last_top = _last_top_key_index(lines, base)
            if last_top < 0:
                at = 1 if lines and lines[0].strip().startswith("{") else 0
            else:
                m_last = _TOP_RE.match(lines[last_top])
                if m_last and m_last.group("val").rstrip().endswith("{"):
                    at = _block_close_index(lines, last_top) + 1
                else:
                    at = last_top + 1
        lines[at:at] = pending
        keys[at:at] = pending_keys

    # ---- 3) 头部 @@locale ----
    if arb_locale is not None:
        want = json.dumps(arb_locale, ensure_ascii=False)
        found = False
        for i, k in enumerate(keys):
            if k == "@@locale":
                lines[i] = f'{base}"@@locale": {want}{"," if _has_comma(lines[i]) else ""}{nl}'
                found = True
                break
        if not found:
            at = 1 if lines and lines[0].strip().startswith("{") else 0
            lines.insert(at, f'{base}"@@locale": {want},{nl}')
            keys.insert(at, "@@locale")

    lines = [l for l in lines if l != ""]

    # ---- 4) 统一规整逗号 ----
    # 先按**当前** lines 重建顶层 key 索引（插入操作会让旧索引失效）。
    top_keys = _top_key_starts(lines, base)
    ci = _close_index_of(lines)
    if top_keys:
        last_top = top_keys[-1]
        m_last = _TOP_RE.match(lines[last_top])
        last_is_block = bool(m_last and m_last.group("val").rstrip().endswith("{"))
        tail_no_comma = _block_close_index(lines, last_top) if last_is_block else last_top

        for idx, i in enumerate(top_keys):
            m = _TOP_RE.match(lines[i])
            if not m:
                continue
            if m.group("val").rstrip().endswith("{"):
                close_i = _block_close_index(lines, i)
                if close_i == tail_no_comma:
                    lines[close_i] = _strip_trailing_comma(lines[close_i])
                elif not _has_comma(lines[close_i]):
                    lines[close_i] = _add_trailing_comma(lines[close_i])
                continue
            if i == tail_no_comma:
                lines[i] = _strip_trailing_comma(lines[i])
            elif not _has_comma(lines[i]):
                lines[i] = _add_trailing_comma(lines[i])

    out = "".join(lines)
    if out and not out.endswith(("\n", "\r")):
        out += nl

    # ---- 5) 写前双重校验 ----
    if out.strip():
        try:
            json.loads(out.replace("\ufeff", ""))
        except json.JSONDecodeError as e:
            raise ValueError(
                f"行级写入后将得到非法 JSON（{e.msg}，第 {e.lineno} 行），已放弃写入\n{path}"
            ) from e

    if existed and not removes:
        # 按 key 比对：原有 key 必须在新文件里仍存在（值可以变，行可以移位）
        old_doc = Doc.from_text(original, doc.base, doc.nl, doc.bom)
        new_doc = Doc.from_text(out, doc.base, doc.nl, doc.bom)
        new_keys = {k for k in old_doc.keys if k}
        lost = [k for k in new_keys if not new_doc.has(k)]
        if lost:
            raise ValueError(
                f"行级写入会丢失 {len(lost)} 个原有 key（{lost[:3]}），已放弃写入\n{path}"
            )

    if dry_run:
        return res

    path.parent.mkdir(parents=True, exist_ok=True)
    data = out.encode("utf-8")
    if doc.bom:
        data = b"\xef\xbb\xbf" + data
    path.write_bytes(data)
    return res


def _close_index_of(lines: list[str]) -> int:
    for i in range(len(lines) - 1, -1, -1):
        if lines[i].strip().startswith("}"):
            return i
    return len(lines)


def _top_key_starts(lines: list[str], base: str) -> list[int]:
    """所有顶层 key 的**起始行号**（含 @元数据块）。"""
    out: list[int] = []
    i = 0
    n = len(lines)
    while i < n:
        s = lines[i].strip()
        if s.startswith("}"):
            i += 1
            continue
        m = _TOP_RE.match(lines[i])
        if m and m.group("ind") == base:
            out.append(i)
            if m.group("val").rstrip().endswith("{"):
                depth = 1
                i += 1
                while i < n and depth > 0:
                    t = lines[i].strip()
                    if t.endswith("{"):
                        depth += 1
                    elif t.startswith("}"):
                        depth -= 1
                    i += 1
                continue
        i += 1
    return out


def _last_top_key_index(lines: list[str], base: str) -> int:
    """最后一个顶层 key 的起始行号（0-based）；没有则 -1。"""
    tops = _top_key_starts(lines, base)
    return tops[-1] if tops else -1


def top_level_order(path: Path) -> list[str]:
    """按文件顺序列出顶层 key（不含 @元数据与 @@locale）。"""
    if not path.exists():
        return []
    doc = Doc.load(path)
    return [
        k for k in doc.keys
        if k and not (k.startswith("@") and k != "@@locale")
    ]