"""阶段 6：机械质检闸门。

全部为确定性规则，不依赖 LLM 自觉。blocking=True 的问题会让整批失败，
产物不写出——这是"写入前机械拦截"的核心。

一条重要教训（来自实测）：简繁/地区用词差异**不能靠字表检测**。
「提交」在简体与台湾档里 codepoint 完全一致却是共通字，按字表比对会大量
误报。必须做词条级检查（glossary.lookup_target），以及"同 key跨档差异"
的显式登记。
"""

from __future__ import annotations

import re

from ..config import Brief, Glossary, cjk_len
from ..models import Entry, QAIssue, Translation, placeholder_signature

# 半角标点紧邻 CJK —— 中文文案里通常是风格不统一
_HALF_PUNCT_NEXT_CJK = re.compile(r"[\u4e00-\u9fff][,;:!?]|[,;:!?][\u4e00-\u9fff]")
_TRAILING_WS = re.compile(r"\s+$")
_URL_IN_TEXT = re.compile(r"https?://|\S+\.(?:com|org|net|io|dev|cn|git)\b|/[A-Za-z0-9_.-]+")


def check_entry(
    entry: Entry,
    tr: Translation,
    brief: Brief,
    glossary: Glossary,
) -> list[QAIssue]:
    """单条译文的全部规则检查。"""
    issues: list[QAIssue] = []
    loc, key = tr.locale, tr.key

    def add(rule, msg, blocking=True, hint=""):
        issues.append(QAIssue(rule, loc, key, msg, blocking, hint))

    # --- R1 占位符签名（最高频事故，必须 block）---
    src_ph = placeholder_signature(entry.source)
    tgt_ph = placeholder_signature(tr.target)
    if src_ph != tgt_ph:
        missing = [p for p in src_ph if p not in tgt_ph]
        extra = [p for p in tgt_ph if p not in src_ph]
        detail = []
        if missing:
            detail.append(f"漏译占位符 {missing}")
        if extra:
            detail.append(f"多出占位符 {extra}")
        add("placeholder_mismatch", "；".join(detail) or f"占位符不一致 {src_ph} vs {tgt_ph}",
            hint=f"源占位符 {list(src_ph)}，译文占位符 {list(tgt_ph)}")

    # --- R2 空译 / 未翻译 ---
    if not tr.target.strip():
        add("empty_translation", "译文为空")
    elif tr.target.strip() == entry.source.strip() and cjk_len(entry.source) > 0:
        add("untranslated", "译文与源文完全相同，疑似漏翻",
            blocking=True, hint="源文含 CJK 但译文原样照抄")

    # --- R3 术语合规（词条级，不靠字表）---
    hits = glossary.lookup_target(tr.target, loc)
    for bad, term, is_forbidden in hits:
        if is_forbidden:
            add("forbidden_term", f"命中禁用译法「{bad}」（术语：{term}）",
                hint="按 glossary.csv 的 forbidden 列修正")
        elif bad and cjk_len(bad) >= 3:
            # 标准译法命中是好事，仅当译文里同时出现别的近似说法才提示
            pass

    # 源文里的术语必须在译文里有对应译法
    for term in glossary.match_in(entry.source):
        std = term.translation_for(loc)
        if std and std not in tr.target:
            add("missing_term", f"术语「{term.term}」应译为「{std}」但未出现",
                hint=f"备注：{term.note}" if term.note else "")

    # --- R4 长度上限（只对 CJK 生效）---
    spec = brief.spec_for(loc)
    if spec.max_length:
        n = cjk_len(tr.target)
        if n > spec.max_length:
            add("too_long", f"CJK 长度 {n} 超过上限 {spec.max_length}",
                hint="超长文案在窄屏 UI 会被截断")

    # --- R5 禁忌短语（brief 级全局规则）---
    for phrase in brief.forbidden_phrases:
        if phrase and phrase in tr.target:
            add("forbidden_phrase", f"命中项目禁忌短语「{phrase}」")

    # --- R6 行尾空格（仅在非 URL/非刻意拼接时告警）---
    if _TRAILING_WS.search(tr.target) and not _URL_IN_TEXT.search(tr.target):
        add("trailing_space", "译文末尾有多余空格", blocking=False,
            hint="若为 UI 拼接留白设计，请在 allowlist 中豁免")

    # --- R7 半角标点混用（仅告警，中文文案常刻意保留半角）---
    if _HALF_PUNCT_NEXT_CJK.search(tr.target) and "http" not in tr.target:
        add("halfwidth_punct", "中文文案中混用半角标点", blocking=False,
            hint="若为团队统一风格，请在 allowlist 中豁免")

    return issues


def check_batch(
    entries: dict[str, Entry],
    translations: list[Translation],
    brief: Brief,
    glossary: Glossary,
) -> list[QAIssue]:
    """整批检查。"""
    out: list[QAIssue] = []
    for tr in translations:
        entry = entries.get(tr.key)
        if entry is None:
            out.append(QAIssue("orphan_key", tr.locale, tr.key, "译文在源文件中无对应 key"))
            continue
        out.extend(check_entry(entry, tr, brief, glossary))
    return out


def cross_locale_consistency(
    by_locale: dict[str, list[Translation]], glossary: Glossary
) -> list[QAIssue]:
    """跨语言一致性：同一 key 在不同地区语言的用词是否符合 glossary 登记。

    这是地区用词差异的机械检测 —— 字表做不到，词条可以。
    """
    issues: list[QAIssue] = []
    locales = list(by_locale.keys())
    index: dict[str, dict[str, Translation]] = {}
    for loc, trs in by_locale.items():
        for tr in trs:
            index.setdefault(tr.key, {})[loc] = tr

    for key, per_loc in index.items():
        for loc, tr in per_loc.items():
            std = None
            for term in glossary.terms:
                t = term.translation_for(loc)
                if t and t in tr.target:
                    std = (term, t)
                    break
            if not std:
                continue
            # 同一 key 在另一档用了别的标准译法 → 说明 glossary 未登记该差异
            for other_loc, other in per_loc.items():
                if other_loc == loc:
                    continue
                other_std = None
                for term in glossary.terms:
                    t = term.translation_for(other_loc)
                    if t and t in other.target:
                        other_std = (term, t)
                        break
                if other_std and other_std[0].term == std[0].term and other_std[1] != std[1]:
                    issues.append(
                        QAIssue(
                            rule="cross_locale_term",
                            locale=f"{loc}/{other_loc}",
                            key=key,
                            message=(
                                f"术语「{std[0].term}」在 {loc} 用「{std[1]}」、"
                                f"在 {other_loc} 用「{other_std[1]}」"
                            ),
                            blocking=False,
                            hint="地区差异请在 glossary.csv 显式登记，否则会被视为漂移",
                        )
                    )
    return issues


def has_blocking(issues: list[QAIssue]) -> bool:
    return any(i.blocking for i in issues)