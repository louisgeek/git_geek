"""阶段 3：翻译记忆库（TM）检索。

命中即免翻 —— 这是控制成本与保证跨批次一致的核心机制。

两级命中：
  1. 精确命中：源文 hash 完全一致
  2. 相似命中：归一化后高度相似（≥ 阈值），复用并标注为相似复用

只有人工审核通过（approved=True）的记录才允许作为权威复用；
未审核的记录仍可用于相似参考，但不直接充当译文。
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from difflib import SequenceMatcher
from pathlib import Path

from ..models import TMRecord, text_hash

DEFAULT_THRESHOLD = 0.92

_PUNCT_RE = re.compile(r"[^\w\u4e00-\u9fff]+")
_WS_RE = re.compile(r"\s+")


def normalize(text: str) -> str:
    """归一化：小写、去标点、压缩空白。用于相似度比较。"""
    t = (text or "").lower()
    t = _PUNCT_RE.sub(" ", t)
    return _WS_RE.sub(" ", t).strip()


def similarity(a: str, b: str) -> float:
    na, nb = normalize(a), normalize(b)
    if not na or not nb:
        return 0.0
    if na == nb:
        return 1.0
    return SequenceMatcher(None, na, nb).ratio()


@dataclass
class TMHit:
    """一次检索的结果。"""

    record: TMRecord | None
    kind: str            # exact | similar | miss
    score: float = 0.0

    @property
    def hit(self) -> bool:
        return self.record is not None and self.kind in ("exact", "similar")


class TranslationMemory:
    """源文指纹 → 多语言译文的记忆库。"""

    def __init__(self, path: Path | None = None, threshold: float = DEFAULT_THRESHOLD):
        self.path = path
        self.threshold = threshold
        self.records: dict[str, TMRecord] = {}

    # ---------- 持久化 ----------

    def load(self) -> "TranslationMemory":
        if self.path and self.path.exists():
            raw = json.loads(self.path.read_text(encoding="utf-8"))
            for item in raw.get("records", []):
                rec = TMRecord(
                    source=item["source"],
                    source_hash=item["source_hash"],
                    translations=item.get("translations", {}),
                    origin=item.get("origin", {}),
                    approved=item.get("approved", False),
                )
                self.records[rec.source_hash] = rec
        return self

    def save(self) -> None:
        if not self.path:
            return
        self.path.parent.mkdir(parents=True, exist_ok=True)
        payload = {
            "version": 1,
            "records": [
                {
                    "source": r.source,
                    "source_hash": r.source_hash,
                    "translations": r.translations,
                    "origin": r.origin,
                    "approved": r.approved,
                }
                for r in sorted(self.records.values(), key=lambda x: x.source_hash)
            ],
        }
        self.path.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8"
        )

    # ---------- 检索 ----------

    def lookup(self, source: str, locale: str) -> TMHit:
        h = text_hash(source)
        rec = self.records.get(h)
        if rec and locale in rec.translations:
            return TMHit(record=rec, kind="exact", score=1.0)

        norm_src = normalize(source)
        best: tuple[float, TMRecord] | None = None
        for r in self.records.values():
            if locale not in r.translations:
                continue
            if normalize(r.source) == norm_src:
                return TMHit(record=r, kind="exact", score=1.0)
            score = similarity(source, r.source)
            if best is None or score > best[0]:
                best = (score, r)
        if best and best[0] >= self.threshold:
            return TMHit(record=best[1], kind="similar", score=round(best[0], 4))
        return TMHit(record=None, kind="miss", score=round(best[0], 4) if best else 0.0)

    def similar_examples(self, source: str, locale: str, limit: int = 3) -> list[tuple[str, str, float]]:
        """给 prompt 用的少样本：找最相似的历史译文。"""
        scored = []
        for r in self.records.values():
            if locale not in r.translations:
                continue
            s = similarity(source, r.source)
            if s >= 0.6:
                scored.append((r.source, r.translations[locale], round(s, 4)))
        scored.sort(key=lambda x: x[2], reverse=True)
        return scored[:limit]

    # ---------- 写入 ----------

    def remember(
        self,
        source: str,
        locale: str,
        target: str,
        origin: str,
        approved: bool = False,
    ) -> TMRecord:
        h = text_hash(source)
        rec = self.records.get(h)
        if rec is None:
            rec = TMRecord(source=source, source_hash=h)
            self.records[h] = rec
        rec.translations[locale] = target
        rec.origin[locale] = origin
        # 人工审核过的译文优先保留 approved 标记
        rec.approved = rec.approved or approved
        return rec

    def approve(self, source: str) -> None:
        rec = self.records.get(text_hash(source))
        if rec:
            rec.approved = True

    def stats(self) -> dict[str, int]:
        approved = sum(1 for r in self.records.values() if r.approved)
        return {
            "records": len(self.records),
            "approved": approved,
            "pending_review": len(self.records) - approved,
        }