"""离线词典驱动的翻译 provider（用于验证管线链路，非生产用）。

## 为什么需要它

`mock` provider 只做英文单词替换，产出的是 `Version {version} is available`
这种中英混杂结果，必然被 QA 闸门拦下——这无法用来验证"管线能否跑通"。

`DictionaryProvider` 用一份**小型英→中词典 + 句式模板**生成真正合规的中文，
让 `run` 的完整链路（装配 → 翻译 → 质检 → 复查 → 写产物 → 清收件箱）
可以在没有 API key 的情况下端到端跑通。

## 它验证什么、不验证什么

**验证**：占位符保真、术语注入生效、长度上限、QA 闸门、复查报告、
收件箱自动出箱、产物写回。

**不验证**：翻译质量。真实项目请用 `--provider openai`。
词典覆盖不到的词会保留英文并被 `untranslated` 规则标出来，
不会静默产出错误译文。
"""

from __future__ import annotations

import re

from ..models import Entry, Translation
from .assemble import AssembledPrompt
from .tm import TranslationMemory

# 句式模板：按 (源文) 精确或模式匹配。
# 顺序即优先级，越具体越靠前。
_PATTERNS: list[tuple[str, str]] = []


def _load_lexicon() -> dict[str, str]:
    """英中词典：短语优先于单词。"""
    return {
        # 完整短语（必须放最前面，长度降序）
        "is available": "可用",
        "Version is available": "版本可用",
        "not available": "不可用",
        # 常见名词
        "Version": "版本",
        "version": "版本",
        "repository": "仓库",
        "Remote": "远程",
        "Local": "本地",
        "Cache": "缓存",
        "Tag": "标签",
        "Commit": "提交",
        "Submodule": "子模块",
        "Branch": "分支",
        "Error": "错误",
        "Warning": "警告",
        "Save": "保存",
        "Cancel": "取消",
        "Close": "关闭",
        "Delete": "删除",
        "Refresh": "刷新",
        "Load": "读取",
        "Fetch": "拉取",
        "Clone": "克隆",
        "Sample": "示例",
        "Missing": "缺失",
        "Failed": "失败",
        "Success": "成功",
        "Diff": "差异",
        "Compare": "对比",
        "Unknown": "未知",
        "Name": "名称",
        "Path": "路径",
        "Count": "数量",
        "Limit": "条数",
        "Status": "状态",
        "Update": "更新",
        "Available": "可用",
        "Diverged": "不一致",
        "All": "全部",
        "Remote repository": "远程仓库",
        # 动词
        "Delete": "删除",
        "is": "是",
        "of": "的",
        "and": "与",
    }


_LEXICON: dict[str, str] | None = None


def _lexicon() -> dict[str, str]:
    global _LEXICON
    if _LEXICON is None:
        _LEXICON = _load_lexicon()
        # 按长度降序，保证长短语先匹配
    return _LEXICON


def _dict_translate(text: str, locale: str) -> str | None:
    """词典翻译。返回 None 表示覆盖不到（应交给真模型）。"""
    lex = _lexicon()
    # 占位符先摘出来，避免被词典误改
    holes: list[str] = []

    def _stash(m: re.Match) -> str:
        holes.append(m.group(0))
        return f"\x00{len(holes) - 1}\x00"

    work = re.sub(r"\{\s*\w+\s*\}", _stash, text)

    # 短语优先（长→短）
    lowered = work
    for en in sorted(lex, key=len, reverse=True):
        if re.search(rf"\b{re.escape(en)}\b", lowered, re.IGNORECASE):
            work = re.sub(rf"\b{re.escape(en)}\b", lex[en], lowered, flags=re.IGNORECASE)
            lowered = work

    # 未被词典覆盖的实义词 → 翻译不完整
    residual = re.findall(r"[A-Za-z]{3,}", work.replace("\x00", ""))
    if residual:
        return None

    # 还原占位符
    def _pop(m: re.Match) -> str:
        return holes[int(m.group(1))]

    work = re.sub(r"\x00(\d+)\x00", _pop, work)
    # 收尾清理
    work = re.sub(r"\s{2,}", " ", work).strip()
    work = re.sub(r"\s+([，。；：！？])", r"\1", work)
    return work or None


class DictionaryProvider:
    """离线词典翻译器。覆盖率有限，仅用于链路验证。"""

    name = "dictionary"

    def __init__(self, glossary=None):
        self.glossary = glossary
        self.calls = 0
        self.uncovered: list[tuple[str, str]] = []

    def translate(self, prompt: AssembledPrompt, entry: Entry) -> str:
        self.calls += 1
        src = entry.source
        out = _dict_translate(src, prompt.locale)

        if out is None:
            # 词典覆盖不到 → 保留源文。QA 的 untranslated 规则会把它标出来，
            # 不会静默产出错误译文。这是有意的：暴露覆盖缺口。
            self.uncovered.append((prompt.locale, src))
            return src

        # 术语注入：把 prompt 里声明的标准译法应用上去
        for term in prompt.hit_terms:
            std = term.translation_for(prompt.locale)
            if not std:
                continue
            # 源文里的术语已被词典译过；这里做一次"确保标准译法存在"
            if term.term.lower() in src.lower() and std not in out:
                out = f"{out}（{std}）" if out else std

        return out


def register() -> None:
    """注册到 provider 工厂。"""
    from . import translate as _t

    _t._EXTRA_PROVIDERS["dictionary"] = lambda glossary: DictionaryProvider(glossary)