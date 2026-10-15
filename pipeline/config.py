"""配置加载：项目描述 brief.yaml + 结构化术语表 glossary.csv。

这是管线的两个"知识输入"。它们不是给人读的文档，而是被
assemble 阶段消费（注入 prompt）、被 qa 阶段消费（机械比对）。

## forbidden 列语法（重要）

    refresh,刷新,重新整理,重新載入,...,zh-Hant:倉庫;zh-Hans:仓库;all:foo,备注

每个条目形如 `<locale>:<译法>`，按 `;` 分隔：

  - `all:<译法>`    —— 对所有语言禁用（也接受无前缀写法）
  - `zh-Hans:<译法>` —— 仅简中禁用
  - `zh-Hant:<译法>` —— 整个繁体桶禁用（台+港都命中）

**无前缀写法视为全局禁用有歧义风险**：写 `A;B` 会被解析成「全局禁用 A」
与「全局禁用 B」，而作者可能想表达「某档禁 A、另一档禁 B」。因此建议
始终带 locale 前缀。桶码（zh-Hant）优于地区码（zh-Hant-TW），因为
后者无法被 `zh_Hant` 这类桶码 locale 反向命中。
"""

from __future__ import annotations

import csv
import hashlib
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import yaml

CJK_RE = re.compile(r"[\u4e00-\u9fff\u3400-\u4dbf]")


def locale_variants(locale: str) -> list[str]:
    """展开 locale 的所有等价写法，从最具体到最宽泛。

    Flutter 的语言桶（zh_Hant）与完整标签（zh-Hant-TW）必须互相命中：
    产物文件名用桶码，brief/glossary 常按完整标签书写。
    顺序即优先级：zh-Hant-TW → zh-Hant → zh_Hant_TW → zh_Hant → zh。

    注意方向性：`locale_variants("zh-Hant-TW")` 会产出 `zh-Hant`，所以
    在 `zh-Hant:` 上声明的规则能被 zh-Hant-TW 命中；反之在
    `zh-Hant-TW:` 上声明的规则不会被 `zh_Hant` 命中。因此**桶级规则
    应写在桶码上**（zh-Hant:），而非具体地区码上。
    """
    loc = locale.strip().replace("_", "-")
    parts = loc.split("-")
    out: list[str] = [loc]
    if len(parts) >= 2:
        out.append("-".join(parts[:2]))          # zh-Hant-TW -> zh-Hant
    if len(parts) >= 3 and parts[1].lower() in ("hans", "hant"):
        out.append(parts[0])# zh-Hant-TW -> zh
    return list(dict.fromkeys(out))


@dataclass(frozen=True)
class Term:
    """一条术语。

    forbidden 支持两种写法：
      - `重新載入;重新整理` —— 对**所有** locale 生效
      - `zh-Hans:仓库  zh-Hant-TW:倉庫` —— 仅对指定 locale 生效

    后者是必需的：同一个词在不同语言里可能既是 A 档的标准译法，
    又是 B 档的禁用译法（如 zh-Hans 的「仓库」正确，而台港禁用「仓库」）。
    全局 forbidden 会把 A 档自己的标准译法判为违规。
    """

    term: str
    translations: dict[str, str]        # locale -> 标准译法
    forbidden: tuple[str, ...] = ()     # 所有 locale 都禁用的译法
    forbidden_by_locale: dict[str, tuple[str, ...]] = field(default_factory=dict)
    note: str = ""

    def translation_for(self, locale: str) -> str | None:
        """取该 locale 的标准译法。

        双向匹配：先按 locale_variants 由具体到宽泛回退（zh-Hant-TW →
        zh-Hant → zh）；仍未命中时，反向查找「键前缀匹配本 locale」的列，
        使写在 zh-Hant 列的译法也能被 zh_Hant / zh-Hant-TW 取到。
        """
        variants = locale_variants(locale)
        for key in variants:
            if key in self.translations:
                return self.translations[key]
        for key, val in self.translations.items():
            if not val:
                continue
            k = key.strip().replace("_", "-")
            if any(k in v or v.startswith(k + "-") for v in variants):
                return val
        return None

    def forbidden_for(self, locale: str) -> tuple[str, ...]:
        """该 locale 下应禁用的全部译法 = 全局 forbidden + 定向 forbidden。

        双向匹配：`zh_Hant` 能命中 `zh-Hant` 与 `zh-Hant-TW` 上的规则，
        `zh-Hant-TW` 也能命中 `zh-Hant` 上的规则。这样术语表里无论把
        台港规则写在桶码（zh-Hant:）还是地区码（zh-Hant-TW:）上都能生效。
        """
        out = list(self.forbidden)
        variants = locale_variants(locale)
        for key in variants:
            out.extend(self.forbidden_by_locale.get(key, ()))
        # 反向：规则挂在更宽的键上（zh-Hant）时，具体地区码（zh-Hant-TW）也要命中
        for rule_key, vals in self.forbidden_by_locale.items():
            rk = rule_key.strip().replace("_", "-")
            if rk in variants:
                continue
            if any(rk in v or v.startswith(rk + "-") for v in variants):
                out.extend(vals)
        return tuple(dict.fromkeys(out))

    def locales_with_translation(self) -> list[str]:
        return [k for k, v in self.translations.items() if v]


@dataclass
class Glossary:
    """术语表。双向索引：源文 term -> Term，译文 -> Term。"""

    terms: list[Term] = field(default_factory=list)
    by_term: dict[str, Term] = field(default_factory=dict)
    # locale -> [(标准译法, 所属 term, 是否禁用)]，供 QA 反查
    by_translation: dict[str, list[tuple[str, str, bool]]] = field(default_factory=dict)
    conflicts: list[str] = field(default_factory=list)

    def validate(self) -> list[str]:
        """自洽性检查。

        核心规则：**禁用译法不得是任何术语在该 locale 的标准译法**。
        违反说明术语表本身写错了 —— 例如给 `local` 登记「繁体档禁用遠端」，
        但「遠端」正是 `remote` 在繁体档的标准译法。这类冲突会让 QA
        闸门把正确译文判为违规，必须在加载期就暴露。
        """
        conflicts: list[str] = []
        locales: set[str] = set()
        for t in self.terms:
            locales.update(t.translations.keys())
        for loc in sorted(locales):
            std_by_locale: dict[str, list[str]] = {}
            for t in self.terms:
                std = t.translation_for(loc)
                if std:
                    std_by_locale.setdefault(std, []).append(t.term)
            for t in self.terms:
                for bad in t.forbidden_for(loc):
                    owners = std_by_locale.get(bad)
                    if owners:
                        conflicts.append(
                            f"[{loc}] 术语「{t.term}」禁用「{bad}」，"
                            f"但该词是术语「{'、'.join(owners)}」的标准译法"
                        )
        # 同一 locale 下两个术语共用一个标准译法（可能是有意的，也可能是漏登记）
        for loc in sorted(locales):
            seen: dict[str, list[str]] = {}
            for t in self.terms:
                std = t.translation_for(loc)
                if std:
                    seen.setdefault(std, []).append(t.term)
            for std, owners in seen.items():
                if len(owners) > 1:
                    conflicts.append(
                        f"[{loc}] 译法「{std}」同时对应术语「{'、'.join(owners)}」，"
                        f"机械检查无法区分，建议合并或加限定说明"
                    )
        self.conflicts = conflicts
        return conflicts

    @property
    def version(self) -> str:
        """术语表版本。参与增量 hash —— 改了术语或禁用译法必须触发重翻。"""
        blob = "|".join(
            f"{t.term}:{sorted(t.translations.items())}:{sorted(t.forbidden)}"
            f":{sorted((k, sorted(v)) for k, v in t.forbidden_by_locale.items())}"
            for t in sorted(self.terms, key=lambda x: x.term)
        )
        return hashlib.sha256(blob.encode("utf-8")).hexdigest()[:12]

    def match_in(self, text: str) -> list[Term]:
        """找出源文中出现的术语。词条级匹配，不用字表（字表会误判简繁共通字）。"""
        low = text.lower()
        return [t for t in self.terms if t.term.lower() in low]

    def lookup_target(self, translation: str, locale: str) -> list[tuple[str, str, bool]]:
        """反查译文命中的术语。

        返回 (命中词, 所属 term, 是否为禁用译法)。
        只用词条级比对 —— 简繁字表会把「提交」这类共通字误判为混用。
        """
        out: list[tuple[str, str, bool]] = []
        for term in self.terms:
            std = term.translation_for(locale)
            if std and std in translation:
                out.append((std, term.term, False))
            for bad in term.forbidden_for(locale):
                if bad and bad in translation:
                    out.append((bad, term.term, True))
        return out


def _parse_forbidden(raw: str) -> tuple[list[str], dict[str, list[str]]]:
    """解析 forbidden 列。

    返回 (全局禁用列表, {locale: [禁用译法]})。
    只有带 `<locale>:` 前缀的条目才归属到该 locale；无前缀归全局。
    """
    glob: list[str] = []
    by_locale: dict[str, list[str]] = {}
    for chunk in (raw or "").split(";"):
        chunk = chunk.strip()
        if not chunk:
            continue
        if ":" in chunk:
            loc, val = chunk.split(":", 1)
            loc, val = loc.strip().replace("_", "-"), val.strip()
            if not loc or not val:
                continue
            if loc.lower() == "all":
                glob.append(val)
            else:
                by_locale.setdefault(loc, []).append(val)
        else:
            glob.append(chunk)
    return glob, by_locale


def load_glossary(path: Path) -> Glossary:
    """加载 CSV 术语表。

    列约定：term, zh-Hans, zh-Hant-TW, ..., forbidden, note
    """
    g = Glossary()
    if not path.exists():
        return g
    with path.open(encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            term = (row.get("term") or "").strip()
            if not term:
                continue
            translations: dict[str, str] = {}
            for col, val in row.items():
                if col in ("term", "forbidden", "note") or not col:
                    continue
                val = (val or "").strip()
                if val:
                    translations[col.strip().replace("_", "-")] = val
            forbidden, by_locale = _parse_forbidden(row.get("forbidden") or "")
            t = Term(
                term=term,
                translations=translations,
                forbidden=tuple(forbidden),
                forbidden_by_locale={k: tuple(v) for k, v in by_locale.items()},
                note=(row.get("note") or "").strip(),
            )
            g.terms.append(t)
            g.by_term[term] = t
    g.validate()
    return g


@dataclass
class LocaleSpec:
    """单个目标语言的规格。"""

    locale: str
    fallback: str = "en"
    rules: list[str] = field(default_factory=list)     # 地区用词提示，注入 prompt
    max_length: int | None = None                     # CJK 字符上限，QA 机械查


@dataclass
class Brief:
    """项目描述。喂 prompt（产品/受众/语气）+ 喂 QA（长度上限/禁忌词）。"""

    product: str = ""
    audience: str = ""
    tone: str = ""
    locales: dict[str, LocaleSpec] = field(default_factory=dict)
    forbidden_phrases: list[str] = field(default_factory=list)
    notes: str = ""

    @property
    def version(self) -> str:
        blob = f"{self.product}|{self.audience}|{self.tone}|{sorted(self.forbidden_phrases)}"
        return hashlib.sha256(blob.encode("utf-8")).hexdigest()[:12]

    def spec_for(self, locale: str) -> LocaleSpec:
        """按 locale_variants 逐级回退匹配，找不到则返回该 locale 的空规格。"""
        for key in locale_variants(locale):
            if key in self.locales:
                return self.locales[key]
        return LocaleSpec(locale=locale)


def load_brief(path: Path) -> Brief:
    """加载 brief.yaml。"""
    b = Brief()
    if not path.exists():
        return b
    data: dict[str, Any] = yaml.safe_load(path.read_text(encoding="utf-8-sig")) or {}
    b.product = data.get("product", "")
    b.audience = data.get("audience", "")
    b.tone = data.get("tone", "")
    b.notes = data.get("notes", "")
    b.forbidden_phrases = [str(x).strip() for x in data.get("constraints", {}).get("forbidden", []) if str(x).strip()]
    for loc, spec in (data.get("per_locale") or {}).items():
        spec = spec or {}
        max_len = spec.get("max_length")
        if max_len is None:
            max_len = (data.get("constraints") or {}).get("max_length_cjk")
        b.locales[loc] = LocaleSpec(
            locale=loc,
            fallback=spec.get("fallback", "en"),
            rules=[str(x).strip() for x in (spec.get("rules") or []) if str(x).strip()],
            max_length=max_len,
        )
    return b


def cjk_len(text: str) -> int:
    """CJK 字符数。长度上限只对 CJK 生效，en 等拉丁语言不适用。"""
    return len(CJK_RE.findall(text or ""))


@dataclass
class SourceSpec:
    """待翻译源的声明。

    **开发者只写这一个文件。** 路径与格式在这里声明一次，
    CLI 不再要求每次传 `--src` / `--format`，避免"路径写错跑错文件"。
    """

    path: Path
    format: str = "arb"
    locale: str = "en"
    # 源里哪些字段算待翻译内容（arb 的 @@locale / @key 元数据等由 adapter 处理）
    description: str = ""


@dataclass
class OutputSpec:
    """产物落地位置。

    **locale → 文件名 的映射必须显式声明。** 产物文件名沿用宿主工程既有的
    命名（如 Flutter 常用 `app_zh_Hant.arb` 表示"繁体台湾桶"），而不是 BCP-47
    标签（`zh-Hant-TW`）。若直接用 `{locale}` 拼接，管线会写出与工程约定
    不匹配的新文件，等于凭空多了一套产物。
    """

    dir: Path
    template: str = "app_{locale}.arb"     # 产物文件名模板
    # locale → 文件名片段。不在表中的 locale 直接用 locale 本身
    file_map: dict[str, str] = field(default_factory=dict)
    baseline_dir: Path | None = None        # 增量基线目录，默认 <dir>/.pipeline
    clean_on_block: bool = True            # 质检阻断时是否清空产物目录

    def target_for(self, locale: str) -> Path:
        """按映射求产物路径。"""
        return self.dir / self.template.format(locale=self.file_name_for(locale))

    def file_name_for(self, locale: str) -> str:
        """locale → 文件名片段（取映射，无映射则用 locale 本身）。"""
        name = self.file_map.get(locale)
        if name is not None:
            return name
        norm = locale.replace("_", "-").lower()
        for k, v in self.file_map.items():
            if k.replace("_", "-").lower() == norm:
                return v
        return locale

    def arb_locale_for(self, locale: str) -> str:
        """locale → 写进 arb `@@locale` 的值。

        Flutter 的 arb 用**语言桶码**（`zh` / `zh_Hant` / `zh_Hant_HK`），
        而 `file_map` 的值恰好就是这套命名，因此直接复用。
        写成 BCP-47 标签（`zh-Hant-TW`）会让 `gen_l10n` 找不到该文件并静默忽略。
        """
        return self.file_name_for(locale)


@dataclass
class PipelineConfig:
    """管线接线配置：源 → 产物 → 增量基线。

    与 Brief / Glossary 的区别：那两个是**知识输入**（喂 LLM 与机械检查），
    这个是**接线配置**（管线路径），不含翻译知识。
    """

    source: SourceSpec
    output: OutputSpec
    locales: list[str] = field(default_factory=list)
    provider: str = "mock"
    tm_path: Path | None = None

    def baseline_path(self, locale: str) -> Path:
        """增量基线路径。`baseline_dir` 即基线目录本身，不再追加子目录。"""
        base = self.output.baseline_dir or (self.output.dir / ".pipeline" / "baseline")
        return base / f"{locale}.json"


def load_pipeline(path: Path) -> PipelineConfig | None:
    """加载 pipeline.yaml。相对路径按配置文件所在目录解析。"""
    if not path.exists():
        return None
    data: dict[str, Any] = yaml.safe_load(path.read_text(encoding="utf-8-sig")) or {}
    root = path.parent.parent  # config/ 的上一级 = 项目根

    src = data.get("source") or {}
    if not src.get("path"):
        return None

    def resolve(p: str) -> Path:
        q = Path(p)
        return q if q.is_absolute() else (root / q)

    out = data.get("output") or {}
    raw_map = out.get("file_map") or {}
    file_map = {
        str(k).strip().replace("_", "-"): str(v).strip()
        for k, v in raw_map.items()
        if str(k).strip() and str(v).strip()
    }
    output = OutputSpec(
        dir=resolve(out.get("dir", "l10n/out")),
        template=out.get("template", "app_{locale}.arb"),
        file_map=file_map,
        baseline_dir=resolve(out["baseline_dir"]) if out.get("baseline_dir") else None,
        clean_on_block=bool(out.get("clean_on_block", True)),
    )
    locales = [str(x).strip() for x in (data.get("locales") or []) if str(x).strip()]
    return PipelineConfig(
        source=SourceSpec(
            path=resolve(src["path"]),
            format=src.get("format", "arb"),
            locale=src.get("locale", "en"),
            description=src.get("description", ""),
        ),
        output=output,
        locales=locales,
        provider=data.get("provider", "mock"),
        tm_path=resolve(data["tm"]) if data.get("tm") else None,
    )