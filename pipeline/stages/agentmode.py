"""Agent 翻译模式：把"谁来翻译"从管线里解耦出来。

## 问题

初版把翻译硬绑在 `OpenAICompatProvider` 上，于是"没 API key 就跑不了"。
但翻译这件事的本质是：**给定上下文与规则，产出一段文本**。
执行者可以是 API 模型、在场的智能体、或一个懂中文的人 —— 管线不该关心。

## 两种 agent 模式

### `export` —— 导出待办
`pipeline run --agent export` 把待翻译条目连同**装配好的上下文**
（brief、命中术语、标准译法、禁用译法、长度上限）导出成一个 JSON 清单。
人/智能体填好 `translation` 字段后，放回同一路径，再跑 `--agent import`。

### `import` —— 回填并落地
读回清单，逐条送进**完全相同的 QA 闸门**，通过才写产物。

## 为什么不直接人肉写 arb

因为那样会绕过闸门：术语不合规、占位符丢失、超长等问题会被直接写进产物。
agent 模式让"谁来翻"自由，但**"翻完必须过检查"不变**。
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field
from pathlib import Path

from ..config import Brief, Glossary
from ..models import Entry
from .assemble import build_prompt


@dataclass
class AgentTask:
    """单条翻译任务。填 `translation` 即可。"""

    key: str
    source: str
    locale: str
    placeholders: tuple[str, ...] = ()
    description: str | None = None
    # 上下文（给翻译者的提示）
    hit_terms: list[str] = field(default_factory=list)      # ["refresh → 重新整理（禁用：重新載入）"]
    locale_rules: list[str] = field(default_factory=list)
    max_length: int | None = None
    # 待填
    translation: str = ""

    def to_json(self) -> dict:
        d = asdict(self)
        d["placeholders"] = list(self.placeholders)
        return d

    @classmethod
    def from_json(cls, d: dict) -> "AgentTask":
        return cls(
            key=d["key"],
            source=d["source"],
            locale=d["locale"],
            placeholders=tuple(d.get("placeholders") or ()),
            description=d.get("description"),
            hit_terms=list(d.get("hit_terms") or []),
            locale_rules=list(d.get("locale_rules") or []),
            max_length=d.get("max_length"),
            translation=d.get("translation", ""),
        )


@dataclass
class AgentManifest:
    """一次导出的清单。"""

    locales: list[str] = field(default_factory=list)
    tasks: list[AgentTask] = field(default_factory=list)

    def to_json(self) -> dict:
        return {
            "_说明": "填好每条的 translation 字段，存回同一路径后跑 --agent import",
            "locales": self.locales,
            "tasks": [t.to_json() for t in self.tasks],
        }

    @classmethod
    def from_json(cls, d: dict) -> "AgentManifest":
        return cls(
            locales=list(d.get("locales") or []),
            tasks=[AgentTask.from_json(t) for t in (d.get("tasks") or [])],
        )

    def unfilled(self) -> list[AgentTask]:
        return [t for t in self.tasks if not t.translation.strip()]

    def by_locale(self) -> dict[str, list[AgentTask]]:
        out: dict[str, list[AgentTask]] = {}
        for t in self.tasks:
            out.setdefault(t.locale, []).append(t)
        return out


def build_task(
    entry: Entry, locale: str, brief: Brief, glossary: Glossary
) -> AgentTask:
    """为单条 Entry 生成任务（含完整上下文）。"""
    spec = brief.spec_for(locale)
    prompt = build_prompt(entry, locale, brief, glossary)

    terms: list[str] = []
    for t in prompt.hit_terms:
        std = t.translation_for(locale)
        if not std:
            continue
        forb = t.forbidden_for(locale)
        line = f"{t.term} → {std}"
        if forb:
            line += f"（禁用：{'、'.join(forb)}）"
        terms.append(line)

    return AgentTask(
        key=entry.key,
        source=entry.source,
        locale=locale,
        placeholders=entry.placeholders,
        description=entry.description,
        hit_terms=terms,
        locale_rules=list(spec.rules),
        max_length=spec.max_length,
    )


def export(
    entries: list[Entry],
    locales: list[str],
    brief: Brief,
    glossary: Glossary,
    only_missing: bool = False,
    existing: dict[str, dict[str, str]] | None = None,
) -> AgentManifest:
    """生成待办清单。`existing` 给出时，`only_missing=True` 可只导出未翻译的。"""
    man = AgentManifest(locales=list(locales))
    for locale in locales:
        have = (existing or {}).get(locale, {})
        for e in entries:
            if only_missing and e.key in have:
                continue
            man.tasks.append(build_task(e, locale, brief, glossary))
    return man


def write_manifest(path: Path, man: AgentManifest) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(man.to_json(), ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def read_manifest(path: Path) -> AgentManifest:
    return AgentManifest.from_json(json.loads(path.read_text(encoding="utf-8-sig")))