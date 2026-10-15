"""管线统一数据模型。

所有 stage 之间只通过这几个结构传递数据，adapter 的差异在此被抹平。
"""

from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass, field, replace
from typing import Any

# ARB / ICU 占位符：{name} 与 {name, type, style}
_PLACEHOLDER_RE = re.compile(r"\{\s*(\w+)\s*(?:,[^{}]*)?\}")


def placeholder_signature(text: str) -> tuple[str, ...]:
    """抽取占位符签名（有序多重集）。

    用于机械比对译文与源文的占位符是否一致 —— 漏译或多译占位符是
    最高频的机器翻译事故，必须在 QA 阶段拦住。
    """
    return tuple(sorted(_PLACEHOLDER_RE.findall(text or "")))


def text_hash(text: str) -> str:
    """源文指纹。用于增量判定。"""
    return hashlib.sha256((text or "").encode("utf-8")).hexdigest()[:16]


@dataclass(frozen=True)
class Entry:
    """一条待翻译条目（源侧）。"""

    key: str
    source: str
    placeholders: tuple[str, ...] = ()
    description: str | None = None      # 源文件里的 @key.description，喂给 LLM 做消歧
    max_length: int | None = None       # 源文件里的 @key 约束

    @property
    def source_hash(self) -> str:
        return text_hash(self.source)


@dataclass(frozen=True)
class Translation:
    """一条译文及其溯源信息。"""

    key: str
    target: str
    locale: str
    origin: str                        # tm_hit | llm | human | fallback_en
    provider: str = ""
    glossary_terms: tuple[str, ...] = ()   # 本条实际命中的术语（溯源用）
    source_hash: str = ""
    note: str = ""

    def with_target(self, target: str) -> "Translation":
        return replace(self, target=target)


@dataclass
class TMRecord:
    """翻译记忆库条目：以源文指纹为键。"""

    source: str
    source_hash: str
    translations: dict[str, str] = field(default_factory=dict)  # locale -> 译文
    origin: dict[str, str] = field(default_factory=dict)        # locale -> 来源
    approved: bool = False                                     # 人工审核通过的才是权威记忆


@dataclass
class QAIssue:
    """一条质检问题。rule 决定是否 block。"""

    rule: str
    locale: str
    key: str
    message: str
    blocking: bool = True
    hint: str = ""

    def __str__(self) -> str:
        flag = "BLOCK" if self.blocking else "WARN"
        loc = f"[{self.locale}]"
        line = f"{flag} {self.rule} {loc} {self.key}: {self.message}"
        return f"{line}\n       ↳ {self.hint}" if self.hint else line


@dataclass
class BatchReport:
    """一次运行的统计。"""

    total: int = 0
    unchanged: int = 0
    tm_hit: int = 0
    llm: int = 0
    fallback_en: int = 0
    blocking_issues: int = 0
    warnings: int = 0
    tokens_in: int = 0
    tokens_out: int = 0

    def as_dict(self) -> dict[str, Any]:
        translated = self.tm_hit + self.llm
        cost_saved = (
            round(self.unchanged / self.total * 100, 1) if self.total else 0.0
        )
        return {
            "total_entries": self.total,
            "unchanged_reused": self.unchanged,
            "tm_hit": self.tm_hit,
            "llm_translated": self.llm,
            "fallback_to_en": self.fallback_en,
            "blocking_issues": self.blocking_issues,
            "warnings": self.warnings,
            "tm_hit_rate": round(self.tm_hit / translated * 100, 1) if translated else 0.0,
            "reuse_rate": cost_saved,
            "tokens_in": self.tokens_in,
            "tokens_out": self.tokens_out,
        }