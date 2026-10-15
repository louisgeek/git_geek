"""复查报告：哪些译文需要人工核验。

## 为什么要单独出报告

机械闸门（qa）能保证**形式合规** —— 占位符不缺、术语不错、长度不超。
但它保证不了**语义正确**。以下情况机器判不了，必须人看：

| 复查原因 | 为什么机器判不了 |
|---|---|
| `llm` 首次翻译 | 机器没有对照基准，这是全新的产出 |
| `tm_similar` 相似命中 | 源文不完全相同，复用的是"接近但不等价"的译文 |
| `fallback_en` 回落英文 | 该语言实际没有译文，用户会看到英文 |
| 术语注入过多 | 一句话命中 ≥4 个术语，很可能是过度约束导致的不自然 |
| 占位符周边文案改动 | 占位符顺序/邻接变化易引发语义漂移 |
| 长度接近上限 | 未超限但已贴近，在窄屏可能被截断 |
| 简繁字形可疑 | 词条级检查覆盖不到的字形混用 |
| 人工登记的译文 | 未经机器校验，需确认没写错语言 |

## 输出

`report.json`（机器可读，供 CI）+ 终端摘要（人可读）。
每条都带 `reason` 与建议动作，方便直接当作 review 清单用。
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field
from pathlib import Path

from ..config import Brief, Glossary, cjk_len
from ..models import Translation

# 术语命中数超过此值，提示过度约束
MANY_TERMS = 4
# 长度达到上限的比例超过此值，提示窄屏风险
LENGTH_RATIO = 0.85

REASON_LABELS = {
    "llm": "机器首次翻译，无对照基准",
    "tm_exact": "TM 精确命中（置信度高，可略过）",
    "tm_similar": "TM 相似命中，源文不完全等价",
    "fallback_en": "回落英文，该语言无译文",
    "many_terms": "术语命中过多，疑似过度约束",
    "placeholders": "含占位符，需确认语义与拼接",
    "near_limit": "长度接近上限，窄屏可能被截断",
    "human": "人工登记，未经机器校验",
    "script_mix": "字形疑似混用",
}


@dataclass
class ReviewItem:
    locale: str
    key: str
    source: str
    target: str
    reasons: list[str] = field(default_factory=list)
    origin: str = ""

    @property
    def severity(self) -> str:
        if any(
            r in ("fallback_en", "tm_similar", "script_mix") for r in self.reasons
        ):
            return "high"
        if any(r in ("llm", "human", "many_terms") for r in self.reasons):
            return "medium"
        return "low"

    def reason_text(self) -> str:
        return "、".join(REASON_LABELS.get(r, r) for r in self.reasons)


def _suspect_script_mix(text: str, locale: str) -> bool:
    """简繁字形疑似混用。

    刻意保守：只查**明确简体独有**的字，且要求同一句里同时出现繁体字。
    词条级检查（qa）覆盖不到的那些漏网之鱼，由这里兜底。
    """
    if "Hant" not in locale.replace("_", "-"):
        return False
    # 简体独有 + 繁体常见
    hans_only = set("们这为国说时间门问题实现动车开关东书网长乐")
    hant_common = set("們這為國說時間門問題實現動車開關東書網長樂")
    has_hans = any(c in hans_only for c in text)
    has_hant = any(c in hant_common for c in text)
    return has_hans and has_hant


def build_review(
    source_by_key: dict[str, str],
    by_locale: dict[str, list[Translation]],
    brief: Brief,
    glossary: Glossary,
    tm_similar_keys: set[tuple[str, str]] | None = None,
) -> list[ReviewItem]:
    """生成复查清单。"""
    tm_similar_keys = tm_similar_keys or set()
    items: list[ReviewItem] = []

    for locale, trs in by_locale.items():
        spec = brief.spec_for(locale)
        max_len = spec.max_length
        for tr in trs:
            reasons: list[str] = []
            src = source_by_key.get(tr.key, "")

            # 来源
            if tr.origin == "llm":
                reasons.append("llm")
            elif tr.origin == "human":
                reasons.append("human")
            elif tr.origin == "fallback_en":
                reasons.append("fallback_en")
            if (locale, tr.key) in tm_similar_keys:
                reasons.append("tm_similar")

            # 术语命中过多
            if glossary:
                hit = len(glossary.match_in(src))
                if hit >= MANY_TERMS:
                    reasons.append("many_terms")

            # 占位符
            if "{" in (tr.target or "") or "{" in src:
                reasons.append("placeholders")

            # 长度接近上限
            if max_len:
                n = cjk_len(tr.target)
                if n >= max_len * LENGTH_RATIO:
                    reasons.append("near_limit")

            # 字形混用
            if _suspect_script_mix(tr.target or "", locale):
                reasons.append("script_mix")

            if reasons:
                items.append(
                    ReviewItem(
                        locale=locale,
                        key=tr.key,
                        source=src,
                        target=tr.target,
                        reasons=reasons,
                        origin=tr.origin,
                    )
                )
    return items


def summarize(items: list[ReviewItem]) -> dict[str, int]:
    out: dict[str, int] = {}
    for it in items:
        out[it.severity] = out.get(it.severity, 0) + 1
    return out


def write_report(
    path: Path,
    items: list[ReviewItem],
    stats: dict,
    issues: list,
    locales: list[str],
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "summary": {
            "review_total": len(items),
            "by_severity": summarize(items),
            **stats,
        },
        "locales": locales,
        "review_items": [
            {**asdict(it), "severity": it.severity, "reason_text": it.reason_text()}
            for it in items
        ],
        "qa_issues": [
            {
                "rule": i.rule,
                "locale": i.locale,
                "key": i.key,
                "message": i.message,
                "blocking": i.blocking,
                "hint": i.hint,
            }
            for i in issues
        ],
    }
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


def print_summary(items: list[ReviewItem], stats: dict, locales: list[str]) -> None:
    sev = summarize(items)
    print(f"\n复查清单：{len(items)} 条待人工核验")
    if sev:
        order = [("high", "高"), ("medium", "中"), ("low", "低")]
        print("  " + "  ".join(f"{label} {sev.get(k, 0)}" for k, label in order))

    by_reason: dict[str, list[ReviewItem]] = {}
    for it in items:
        for r in it.reasons:
            by_reason.setdefault(r, []).append(it)
    if by_reason:
        print("\n按原因：")
        for r, group in sorted(by_reason.items(), key=lambda x: -len(x[1])):
            locs = sorted({g.locale for g in group})
            print(f"  {REASON_LABELS.get(r, r):<22} {len(group):>4} 条   {','.join(locs)}")

    high = [it for it in items if it.severity == "high"]
    if high:
        print(f"\n高优先级（前 10 条，建议优先处理）：")
        for it in high[:10]:
            print(f"  [{it.locale}] {it.key}")
            print(f"      en: {it.source[:56]}")
            print(f"      {it.locale}: {it.target[:56]}")
            print(f"      原因：{it.reason_text()}")
    if len(high) > 10:
        print(f"  …另有 {len(high) - 10} 条高优先级，详见 report.json")
