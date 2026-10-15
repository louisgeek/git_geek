"""源文件 adapter：把各种格式抹平成 Entry 序列。

新增格式只需实现 `extract()`，其余 stage 无需改动。
"""

from __future__ import annotations

import csv
import json
import re
from pathlib import Path
from typing import Callable

from ..models import Entry, placeholder_signature

ExtractFn = Callable[[Path], list[Entry]]

_REGISTRY: dict[str, ExtractFn] = {}


def register(fmt: str) -> Callable[[ExtractFn], ExtractFn]:
    def deco(fn: ExtractFn) -> ExtractFn:
        _REGISTRY[fmt] = fn
        return fn

    return deco


def get_adapter(fmt: str) -> ExtractFn:
    if fmt not in _REGISTRY:
        raise ValueError(f"未知源格式 {fmt!r}，已注册: {sorted(_REGISTRY)}")
    return _REGISTRY[fmt]


@register("arb")
def _extract_arb(path: Path) -> list[Entry]:
    """Flutter ARB。@key 元数据与同名 value 成对，value 是源文。"""
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    out: list[Entry] = []
    for key, val in data.items():
        if key.startswith("@") or key == "@@locale":
            continue
        if not isinstance(val, str):
            continue
        meta = data.get(f"@{key}") or {}
        out.append(
            Entry(
                key=key,
                source=val,
                placeholders=placeholder_signature(val),
                description=meta.get("description"),
                max_length=meta.get("maxLength"),
            )
        )
    return out


@register("json")
def _extract_json(path: Path) -> list[Entry]:
    """嵌套 JSON，用点号路径作 key。"""
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    out: list[Entry] = []

    def walk(node: object, prefix: str = "") -> None:
        if isinstance(node, dict):
            for k, v in node.items():
                walk(v, f"{prefix}.{k}" if prefix else str(k))
        elif isinstance(node, str):
            out.append(
                Entry(
                    key=prefix,
                    source=node,
                    placeholders=placeholder_signature(node),
                )
            )

    walk(data)
    return out


@register("csv")
def _extract_csv(path: Path) -> list[Entry]:
    """两列 CSV：key,source。可选第三列 description。"""
    out: list[Entry] = []
    with path.open(encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        fields = [x.lower() for x in (reader.fieldnames or [])]
        src_col = "source" if "source" in fields else fields[1]
        desc_col = "description" if "description" in fields else None
        for row in reader:
            key = (row.get("key") or "").strip()
            src = (row.get(src_col) or "").strip()
            if not key or not src:
                continue
            out.append(
                Entry(
                    key=key,
                    source=src,
                    placeholders=placeholder_signature(src),
                    description=(row.get(desc_col) or "").strip() if desc_col else None,
                )
            )
    return out


@register("po")
def _extract_po(path: Path) -> list[Entry]:
    """GNU gettext PO。msgid 为源文，msgctxt 优先作 key。"""
    text = path.read_text(encoding="utf-8-sig")
    entries: list[Entry] = []
    msgid = ""
    ctxt = ""
    mode = None
    for line in text.splitlines():
        line = line.strip()
        if line.startswith("msgctxt "):
            ctxt, mode = _po_unquote(line[8:]), "ctxt"
        elif line.startswith("msgid "):
            msgid, mode = _po_unquote(line[6:]), "id"
        elif line.startswith('"'):
            chunk = _po_unquote(line)
            if mode == "id":
                msgid += chunk
            elif mode == "ctxt":
                ctxt += chunk
        elif line == "" and msgid:
            key = ctxt or msgid
            entries.append(
                Entry(key=key, source=msgid, placeholders=placeholder_signature(msgid))
            )
            msgid = ctxt = ""
            mode = None
    if msgid:
        key = ctxt or msgid
        entries.append(Entry(key=key, source=msgid, placeholders=placeholder_signature(msgid)))
    return entries


def _po_unquote(s: str) -> str:
    s = s.strip()
    if len(s) >= 2 and s[0] == '"' and s[-1] == '"':
        s = s[1:-1]
    return s.encode("utf-8").decode("unicode_escape").encode("latin-1").decode("utf-8", "ignore") if "\\" in s else s


@register("md")
def _extract_md(path: Path) -> list[Entry]:
    """Markdown：按标题分块，key 为标题 slug。适合文档类本地化。"""
    out: list[Entry] = []
    title = ""
    buf: list[str] = []
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        m = re.match(r"^(#{1,6})\s+(.*)$", line)
        if m:
            if title and buf:
                body = "\n".join(buf).strip()
                if body:
                    out.append(
                        Entry(
                            key=_slugify(title),
                            source=body,
                            placeholders=placeholder_signature(body),
                        )
                    )
            title, buf = m.group(2).strip(), []
        elif title:
            buf.append(line)
    if title and buf:
        body = "\n".join(buf).strip()
        if body:
            out.append(
                Entry(key=_slugify(title), source=body, placeholders=placeholder_signature(body))
            )
    return out


def _slugify(s: str) -> str:
    return re.sub(r"[^\w\u4e00-\u9fff]+", "-", s.strip().lower()).strip("-")