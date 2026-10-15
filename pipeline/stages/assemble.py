"""阶段 4：上下文装配。

这一步是 brief 与 glossary 被"消费"的地方，而不是被人阅读。

装配原则：
  1. 只注入**本条命中**的术语，不把整张术语表灌进 prompt（省 token + 降干扰）
  2. brief 的产品/受众/语气作为稳定前缀，每个 locale 一份 system 段
  3. TM 的相似历史译文作为少样本，让模型模仿既有风格而非自由发挥
  4. 占位符签名显式复述，防止模型改写 {name}
"""

from __future__ import annotations

from dataclasses import dataclass, field

from ..config import Brief, Glossary, Term
from ..models import Entry
from .tm import TranslationMemory

SYSTEM_TEMPLATE = """你是产品本地化专家，为「{product}」翻译界面文案。

受众：{audience}
语气：{tone}
{extra}硬性规则：
1. 占位符必须原样保留：{placeholders}
2. 只输出译文，不要解释、不要加引号、不要重复原文
3. 保持简洁，不要添加原文没有的信息"""

LOCALE_RULES_HEADER = """
本语言（{locale}）特定规则：
{rules}"""


@dataclass
class AssembledPrompt:
    """装配好的单条翻译请求。"""

    system: str
    user: str
    locale: str
    hit_terms: tuple[Term, ...] = ()
    examples: tuple[tuple[str, str], ...] = ()
    tokens_estimate: int = 0


def build_prompt(
    entry: Entry,
    locale: str,
    brief: Brief,
    glossary: Glossary,
    tm: TranslationMemory | None = None,
    few_shot_limit: int = 3,
) -> AssembledPrompt:
    """为单条 Entry 装配翻译 prompt。"""
    spec = brief.spec_for(locale)

    extra = ""
    if brief.notes:
        extra += f"补充要求：{brief.notes}\n"
    if spec.rules:
        extra += LOCALE_RULES_HEADER.format(
            locale=locale, rules="\n".join(f"- {r}" for r in spec.rules)
        ) + "\n"
    if spec.max_length:
        extra += f"长度上限：{spec.max_length} 个字符以内\n"

    hit_terms = glossary.match_in(entry.source)
    if hit_terms:
        extra += "\n本条必须遵守的术语（译法唯一，勿用同义替换）：\n"
        for t in hit_terms:
            std = t.translation_for(locale)
            if std:
                # 禁用译法按 locale 取，避免把 A 档的标准译法当成禁用项
                forb = t.forbidden_for(locale)
                forb_text = f"　禁用：{'、'.join(forb)}" if forb else ""
                extra += f"- {t.term} → {std}{forb_text}\n"
                if t.note:
                    extra += f"  （{t.note}）\n"

    ph_text = (
        "、".join(f"{{{p}}}" for p in entry.placeholders) if entry.placeholders else "（本条无占位符）"
    )
    system = SYSTEM_TEMPLATE.format(
        product=brief.product or "该产品",
        audience=brief.audience or "终端用户",
        tone=brief.tone or "简洁准确",
        extra=extra,
        placeholders=ph_text,
    )

    user = entry.source
    if entry.description:
        user = f"{entry.source}\n\n[上下文：{entry.description}]"

    examples: tuple[tuple[str, str], ...] = ()
    if tm is not None:
        raw = tm.similar_examples(entry.source, locale, limit=few_shot_limit)
        examples = tuple((s, t) for s, t, _ in raw)
        if examples:
            shots = "\n\n".join(f"原文：{s}\n译文：{t}" for s, t in examples)
            system += f"\n\n参考以下既有译文，保持措辞风格一致：\n{shots}"

    prompt = AssembledPrompt(
        system=system,
        user=user,
        locale=locale,
        hit_terms=tuple(hit_terms),
        examples=examples,
        tokens_estimate=(len(system) + len(user)) // 2,
    )
    return prompt


def batch_prompts(
    entries: list[Entry],
    locale: str,
    brief: Brief,
    glossary: Glossary,
    tm: TranslationMemory | None = None,
) -> list[AssembledPrompt]:
    """批量装配。system 前缀在同一 locale 下共享，实际调用时可缓存复用。"""
    return [build_prompt(e, locale, brief, glossary, tm) for e in entries]