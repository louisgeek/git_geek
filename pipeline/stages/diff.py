"""阶段 2：增量判定。

关键设计：增量指纹 = hash(源文) ⊕ glossary版本 ⊕ brief版本 ⊕ 目标语言。

只比源文 hash 是不够的 —— 改了术语表或项目描述后，即使源文没变，
译文也可能过时。把这三者编进同一个指纹，才能保证"改了知识输入就重翻"。
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum

from ..models import Entry, Translation


class ChangeKind(str, Enum):
    NEW = "new"              # 首次出现
    SOURCE_CHANGED = "changed"  # 源文变了
    CONTEXT_CHANGED = "ctx_changed"  # 源文没变，但术语表/brief 变了
    UNCHANGED = "unchanged"  # 完全没变，直接复用
    REMOVED = "removed"      # 源里已删


@dataclass(frozen=True)
class EntryFingerprint:
    """单条条目的增量指纹。"""

    source_hash: str
    glossary_version: str
    brief_version: str
    locale: str

    def as_str(self) -> str:
        return f"{self.source_hash}.{self.glossary_version}.{self.brief_version}.{self.locale}"


@dataclass
class ChangePlan:
    """一次增量判定的结果。"""

    kind: ChangeKind
    entry: Entry
    locale: str
    reusable: Translation | None = None    # 可直接复用的旧译文

    @property
    def needs_translation(self) -> bool:
        return self.kind in (ChangeKind.NEW, ChangeKind.SOURCE_CHANGED, ChangeKind.CONTEXT_CHANGED)


def fingerprint(entry: Entry, glossary_version: str, brief_version: str, locale: str) -> EntryFingerprint:
    return EntryFingerprint(
        source_hash=entry.source_hash,
        glossary_version=glossary_version,
        brief_version=brief_version,
        locale=locale,
    )


def diff(
    entries: list[Entry],
    baseline: dict[str, str],
    glossary_version: str,
    brief_version: str,
    locale: str,
) -> list[ChangePlan]:
    """比对基线，产出逐条变更计划。

    baseline: {fingerprint_str: {"target":..., "origin":...}}
    """
    plans: list[ChangePlan] = []
    for entry in entries:
        fp = fingerprint(entry, glossary_version, brief_version, locale)
        fp_str = fp.as_str()
        if fp_str in baseline:
            rec = baseline[fp_str]
            plans.append(
                ChangePlan(
                    kind=ChangeKind.UNCHANGED,
                    entry=entry,
                    locale=locale,
                    reusable=Translation(
                        key=entry.key,
                        target=rec["target"],
                        locale=locale,
                        origin=rec.get("origin", "human"),
                        source_hash=entry.source_hash,
                    ),
                )
            )
            continue

        # 指纹没命中：判断是源文变了，还是仅上下文变了
        old = _find_same_source(entries, entry, baseline)
        kind = ChangeKind.CONTEXT_CHANGED if old else ChangeKind.SOURCE_CHANGED
        plans.append(ChangePlan(kind=kind, entry=entry, locale=locale))
    return plans


def _find_same_source(entries: list[Entry], entry: Entry, baseline: dict[str, str]) -> str | None:
    """在基线里找同 key 且源文 hash 相同的记录 → 说明只是上下文变了。"""
    for fp_str, rec in baseline.items():
        if rec.get("key") == entry.key and rec.get("source_hash") == entry.source_hash:
            return rec["target"]
    return None


def diff_removals(
    entries: list[Entry], baseline: dict[str, str], locale: str
) -> list[str]:
    """源里已删除但基线还在的 key。"""
    current = {e.key for e in entries}
    removed = []
    for rec in baseline.values():
        if rec.get("locale") == locale and rec.get("key") not in current:
            removed.append(rec["key"])
    return removed