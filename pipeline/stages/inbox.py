r"""收件箱（inbox）：人工只写这里，产品文件由管线维护。

## 文件位置与格式

`lib/shared/l10n/arb/inbox.json` —— 与各语言文件平级。

    "btnSave": "Save changes"
    "newVersion": "Version {version} is available"
    -- zh-Hant-TW
    "btnSave": "儲存變更"
    "btnSave": "保存" --replace
    "btnSave": "Save changes" -- 主按钮，最短

外层 `{}` 是可选的：写了就是标准 JSON（去掉 `//` 注释行后能被 `jq`/
`json.loads` 直接读），不写就是纯 key-value 列表。两种都支持。

**为什么 `.json` 是安全的**：Flutter 源码
（`flutter_tools/lib/src/localizations/gen_l10n_types.dart`）里写死了扫描规则：

    final filenameRE = RegExp(r'(\w+)\.arb$');
    directory.listSync().whereType<File>()
        .where((e) => filenameRE.hasMatch(e.path))

**只扫 `.arb`，其他后缀一律不看。** 因此 `arb-dir` 下的 `.json`
（以及 `.txt`、`.strings` 等）都不会被 `gen_l10n` 解析或报警。
已实测：`inbox.json` 放进去，`flutter gen-l10n` 退出码 0、零警告、
生成产物里不含它的 key。

唯一需要避开的是 `.arb` —— 它匹配上面的正则，会被当成语言文件，
且因为无法从文件名推断 locale 而报 `locale could not be determined`。

注意：`//` 注释行会让文件**不是**合法 JSON（去掉注释行后是），
因为 JSON 不支持 `//` 注释。工具自己读写不受影响。

## 语法（故意做得极简）

| 写法 | 含义 |
|---|---|
| `// ...` | 注释，忽略 |
| `"key": "文案"` | 一条文案 |
| `-- zh-Hant-TW` | 切换目标语言，影响后续所有条目 |
| `--replace` | 允许覆盖已有 key |
| `-- 说明文字` | 给翻译模型的提示 |

不用 JSON 对象、不用嵌套。JSONL 时代一条要写
`{"key": "x", "text": "y", "replace": true}`，噪音比信息多。

## 为什么要有收件箱这一层

若人工直接写产品文件（app_*.arb）：
1. **并发冲突** —— 两人同时改同一个 arb，git 上直接打架
2. **职责混淆** —— 产品文件既有人工历史又混入机器产物，来源不可辨
3. **无法审计** —— 不知道某条是人写的还是机器翻的、何时加的
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

from ..config import Glossary, PipelineConfig, cjk_len

INBOX_FILENAME = "inbox.json"

INBOX_HEADER = """\
// ============================================================================
// 待翻译文案收件箱 —— 人工只写这个文件
// 格式：  "key": "文案"
// ============================================================================
//
// 放新文案（源文，写英文）：
//   "btnSave": "Save changes"
//
// 带占位符（{} 内是变量，翻译时要原样保留）：
//   "newVersion": "Version {version} is available"
//
// 补某个语言的译文（用 -- 行指定语言，影响后续所有条目）：
//   -- zh-Hant-TW
//   "btnSave": "儲存變更"
//
// 覆盖已有 key（必须显式声明 --replace）：
//   "btnSave": "保存" --replace
//
// 给翻译模型的提示（文案后用 -- 开头）：
//   "btnSave": "Save changes" -- 主按钮，最短
//
// 也可用命令行登记：
//   python -m pipeline add --key btnSave --text "Save changes"
//
// 流程：  inbox → ingest（去重+落地到 app_en.arb） → run（翻译+出报告）
// 查看：  python -m pipeline inbox
//
// 本文件是 append-only 的，请勿重排或删除已有行 —— 冲突面越小越好合并。
// 每次 ingest/run 成功后，已处理完的条目会自动移除。
// ============================================================================
{
}
"""

# "key": "value"  —— value 允许含转义引号
_ENTRY_RE = re.compile(r'^\s*"(?P<key>[^"]+)"\s*:\s*"(?P<value>(?:[^"\\]|\\.)*)"\s*(?P<flags>.*)$')
# 行尾标记：--replace / -- 说明文字
_FLAG_RE = re.compile(r"--\s*(?P<body>.*)$")
# 语言切换：-- zh-Hant-TW（纯语言码，无其他文字）
_LOCALE_RE = re.compile(r"^[A-Za-z]{2,3}(?:[-_][A-Za-z0-9]{2,8})*$")
_KEY_RE = re.compile(r"^[A-Za-z][A-Za-z0-9_]*$")


def _unquote(value: str) -> str:
    """还原 JSON 风格的转义（主要处理 \" 与 \\）。"""
    return (
        value.replace('\\"', '"').replace("\\\\", "\\").replace("\\n", "\n").replace("\\t", "\t")
    )


@dataclass
class InboxItem:
    """收件箱里的一条待处理记录。"""

    key: str
    text: str
    locale: str | None = None      # None = en 源
    description: str | None = None
    replace: bool = False
    ts: str = ""
    line_no: int = 0

    @property
    def is_source(self) -> bool:
        return self.locale is None

    def render(self, with_comma: bool = False) -> str:
        """渲染回源码行（append 时用）。

        with_comma=True 用于 JSON 对象写法（需要补逗号）。
        """
        val = self.text.replace("\\", "\\\\").replace('"', '\\"')
        line = f'"{self.key}": "{val}"'
        if self.replace:
            line += " --replace"
        if self.description:
            line += f" -- {self.description}"
        if with_comma:
            line += ","
        return line


@dataclass
class Inbox:
    """收件箱文件。append-only 文本。"""

    path: Path
    items: list[InboxItem] = field(default_factory=list)
    malformed: list[tuple[int, str]] = field(default_factory=list)

    @classmethod
    def load(cls, path: Path) -> "Inbox":
        box = cls(path=path)
        if not path.exists():
            return box

        current_locale: str | None = None
        for i, raw in enumerate(
            path.read_text(encoding="utf-8-sig").splitlines(), start=1
        ):
            line = raw.strip()
            if not line:
                continue
            if line.startswith("//"):
                continue

            # JSON 对象的括号行（两种写法都可能出现）
            if line in ("{", "}", "},", "{,"):
                continue

            # 语言切换行：-- zh-Hant-TW / -- en（回到源语言）
            if line.startswith("--"):
                body = line[2:].strip()
                if _LOCALE_RE.match(body):
                    norm = body.replace("_", "-")
                    # `-- en` 等价于"无语言"（写 en 源），归一到 None
                    current_locale = None if norm.lower() == "en" else norm
                continue

            # 带逗号的写法（JSON 对象内的标准形式）："key": "value",
            m = _ENTRY_RE.match(line.rstrip(","))
            if not m:
                box.malformed.append(
                    (i, f'无法解析（期望 "key": "文案"）：{line[:50]}')
                )
                continue

            key = m.group("key").strip()
            text = _unquote(m.group("value"))
            flags = m.group("flags") or ""

            replace = False
            description: str | None = None
            if "--" in flags:
                body = flags.split("--", 1)[1].strip()
                if body.lower() in ("replace", "replace=true"):
                    replace = True
                elif body:
                    description = body

            if not key:
                box.malformed.append((i, "key 为空"))
                continue
            if not text.strip():
                box.malformed.append((i, "文案为空"))
                continue
            if not _KEY_RE.match(key):
                box.malformed.append(
                    (i, f"key「{key}」不合法：只允许字母、数字、下划线，且以字母开头")
                )
                continue

            box.items.append(
                InboxItem(
                    key=key,
                    text=text,
                    locale=current_locale,
                    description=description,
                    replace=replace,
                    line_no=i,
                )
            )
        return box

    def append(self, item: InboxItem) -> None:
        """追加一条。永不重排既有行。文件不存在时自动创建并写入文件头。"""
        item.ts = item.ts or datetime.now(timezone.utc).isoformat(timespec="seconds")
        self.path.parent.mkdir(parents=True, exist_ok=True)
        if not self.path.exists() or self.path.stat().st_size == 0:
            self.path.write_text(INBOX_HEADER, encoding="utf-8")

        # 语言切换前缀：
        #   - 指定语言且与最后一条不同 → 加 `-- locale` 行
        #   - **不指定语言但最后一条有语言** → 必须显式切回，否则会被
        #     解析成那个语言的条目（`--` 行是"粘性"的，影响后续所有行）
        prefix = ""
        last_locale = self.items[-1].locale if self.items else None
        if item.locale:
            if last_locale != item.locale:
                prefix = f"-- {item.locale}\n"
        elif last_locale is not None:
            prefix = "-- en\n"

        nl = "\n"
        if self.path.exists():
            raw = self.path.read_bytes()
            if b"\r\n" in raw:
                nl = "\r\n"

        # JSON 对象写法必须插到 `}` 之前，否则破坏结构
        if _json_braced(self.path):
            text = self.path.read_text(encoding="utf-8-sig")
            lines = text.splitlines(keepends=True)
            close_at = None
            for idx in range(len(lines) - 1, -1, -1):
                if lines[idx].strip().startswith("}"):
                    close_at = idx
                    break
            if close_at is not None:
                # 新条目缩进：跟随 `}` 之前那条已有条目的缩进
                base = _entry_indent(lines, close_at)
                # 「前一条」与「是新条目的后继」都需要逗号：
                #   * 若 `}` 前一行已是条目 → 它在前面，要补逗号；新条目在最后，不补
                #   * 若 `}` 前一行是注释/空行 → 新条目也是最后，不补
                prev_is_entry = (
                    close_at > 0 and _ENTRY_RE.match(lines[close_at - 1].rstrip("\r\n").rstrip(","))
                    is not None
                )
                if prev_is_entry:
                    prev = lines[close_at - 1].rstrip("\r\n").rstrip()
                    if not prev.endswith(","):
                        had_nl = lines[close_at - 1].endswith(("\n", "\r"))
                        lines[close_at - 1] = prev + "," + (nl if had_nl else "")
                    need_comma = False  # 新条目成了最后一条
                else:
                    need_comma = False

                rendered = (prefix + item.render(with_comma=need_comma)).splitlines()
                new = [(base + l.strip() if l.strip() and not l.startswith("--") else l) + nl
                       for l in rendered]
                body = "".join(lines[:close_at]) + "".join(new) + "".join(lines[close_at:])
                with self.path.open("w", encoding="utf-8", newline="") as f:
                    f.write(body)
                self.items.append(item)
                return

        with self.path.open("a", encoding="utf-8", newline="") as f:
            f.write(prefix + item.render() + nl)
        self.items.append(item)

    def clear(self, consumed_lines: list[int]) -> None:
        """移除已处理的条目，保留文件头。

        连带清理两种残留：
          1. 被删条目**后面**紧跟的孤立语言切换行（删了条目切换行就没用了）
          2. 文件末尾的孤立语言切换行
        """
        if not self.path.exists() or not consumed_lines:
            return
        lines = self.path.read_text(encoding="utf-8-sig").splitlines()
        drop = set(consumed_lines)

        def is_locale_switch(idx0: int) -> str | None:
            """0-based 索引处是否是语言切换行，是则返回语言码。"""
            if 0 <= idx0 < len(lines):
                s = lines[idx0].strip()
                if s.startswith("--"):
                    body = s[2:].strip()
                    if _LOCALE_RE.match(body):
                        return body
            return None

        # 孤立语言切换行的判断统一在下面的主循环里做：
        # 一行切换行若后面没有任何同语言条目（或干脆没条目），就一并删除。
        # 这里不预先把切换行塞进 drop，否则主循环会先命中 `i in drop` 而跳过判断。

        kept: list[str] = []
        for i, l in enumerate(lines, start=1):
            if i in drop:
                continue
            s = l.strip()
            if s.startswith("//") or not s:
                kept.append(l)
                continue
            # JSON 对象的括号行必须保留
            if s in ("{", "}", "},", "{,"):
                kept.append(l)
                continue
            # 孤立语言切换行清理（i 是 1-based，往后扫从 i 之后开始）
            loc = is_locale_switch(i - 1)
            if loc is not None:
                nxt = ""
                for k in range(i, len(lines)):
                    if (k + 1) in drop:
                        continue  # 该行本轮就要删掉，不能算作"后面还有内容"
                    t = lines[k].strip()
                    if not t or t.startswith("//"):
                        continue
                    nxt = t
                    break
                if not nxt:
                    continue  # 后面没有任何条目 → 孤立，删
                if nxt.startswith("--") and nxt[2:].strip() != loc:
                    continue  # 后面是别的语言 → 孤立，删
            kept.append(l)

        out = "\n".join(kept).rstrip("\n")
        self.path.write_text((out + "\n") if out else "", encoding="utf-8")
        self.items = [
            InboxItem(
                key=it.key, text=it.text, locale=it.locale, description=it.description,
                replace=it.replace, ts=it.ts,
            )
            for it in self.items
            if it.line_no not in drop
        ]


def validate_new_item(
    key: str, text: str, existing_keys: set[str], replace: bool
) -> tuple[bool, str]:
    if not key:
        return False, "key 不能为空"
    if not _KEY_RE.match(key):
        return False, f"key「{key}」不合法：只允许字母、数字、下划线，且以字母开头"
    if key in existing_keys and not replace:
        return False, f"key「{key}」已存在；如确需覆盖请加 --replace"
    if not text.strip():
        return False, "文案不能为空"
    return True, "ok"


def preview_warnings(
    item: InboxItem, glossary: Glossary | None, max_len: int | None
) -> list[str]:
    """写入前提示（术语命中、长度、CJK 混入、占位符缺描述等）。"""
    warns: list[str] = []
    if glossary:
        if item.is_source:
            for t in glossary.match_in(item.text):
                std = "、".join(f"{k}={v}" for k, v in sorted(t.translations.items()))
                warns.append(f"命中术语「{t.term}」：{std}")
        else:
            for bad, term, is_forbidden in glossary.lookup_target(item.text, item.locale or ""):
                if is_forbidden:
                    warns.append(f"⚠ 命中 {item.locale} 禁用译法「{bad}」（术语：{term}）")
    if max_len:
        n = cjk_len(item.text)
        if n > max_len:
            warns.append(f"⚠ CJK 长度 {n} 超过上限 {max_len}")
    if item.is_source and cjk_len(item.text):
        warns.append(f"⚠ 源文含 {cjk_len(item.text)} 个 CJK 字符，通常意味着漏翻")
    from ..models import placeholder_signature

    if item.is_source and placeholder_signature(item.text) and not item.description:
        warns.append("源文含占位符，建议补提示（文案后加 -- 说明）帮模型消歧")
    return warns


def inbox_path_for(cfg: PipelineConfig) -> Path:
    """收件箱位置：**与各语言文件同目录**。

    放在 `lib/shared/l10n/arb/inbox.json` 而不是隐藏子目录，理由是可见性：
    开发者打开 l10n 目录就该能看到"该写哪个文件"。
    命名与 `app_*.arb` 不冲突，`gen_l10n` 只扫 `.arb`（源码已确认 + 实测）。
    """
    return cfg.source.path.parent / INBOX_FILENAME


def _entry_indent(lines: list[str], before: int) -> str:
    """取 `before` 位置之前最近一条**已有条目**的缩进（JSON 对象写法用）。

    跳过注释行与 JSON 括号行 —— `{` 是顶格，若把它当参考会返回空缩进。
    空对象（只有 `{ }`）时退化为默认 2 空格。
    """
    for i in range(before - 1, -1, -1):
        s = lines[i].strip()
        if not s or s.startswith("//") or s.startswith("--"):
            continue
        if s.startswith("{") or s.startswith("}"):
            continue  # JSON 括号行不代表条目缩进
        return lines[i][: len(lines[i]) - len(lines[i].lstrip())]
    return "  "


def _json_braced(path: Path) -> bool:
    """收件箱是否用了 JSON 对象包裹（首行是 `{`）。

    两种写法都要支持：
        {                          {"a": "A"}
          "a": "A"          ←───→
        }                          {"b": "B"}
                                  }
    带包裹时 `append` 必须插到 `}` 之前并补逗号，否则破坏 JSON 结构。
    """
    if not path.exists():
        return False
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        s = line.strip()
        if not s or s.startswith("//"):
            continue
        return s.startswith("{")
    return False
