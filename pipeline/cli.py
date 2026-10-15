"""翻译管线 CLI。

**开发者只写一个文件**：`config/pipeline.yaml` 里 `source.path` 声明的
en 源文件。其余（产物位置、目标语言、增量基线）也在该文件里声明一次。

新增一条待翻译文案：
    python -m pipeline new --key btnFoo --text "Foo button"

跑完整管线（无需再传路径与语言）：
    python -m pipeline run

管道顺序：
    extract → diff → tm → assemble → translate → qa → emit
任一 blocking 问题 ⇒ 不写产物，退出码 2。
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from .adapters import sources as source_adapters
from .config import load_brief, load_glossary, load_pipeline
from .models import BatchReport, QAIssue, Translation
from .stages import (
    assemble,
    dedup as dedup_stage,
    diff as diff_stage,
    emit,
    inbox,
    newsrc,
    qa,
    review,
    tm as tm_stage,
    translate,
)

DEFAULT_CONFIG_DIR = Path(__file__).parent / "config"
DEFAULT_CACHE = Path(__file__).parent / ".cache"


def _load_config(args) -> tuple:
    """加载 brief / glossary / pipeline 三份配置。"""
    cfg_dir = Path(args.config) if getattr(args, "config", None) else DEFAULT_CONFIG_DIR
    brief = load_brief(cfg_dir / "brief.yaml")
    glossary = load_glossary(cfg_dir / "glossary.csv")
    return brief, glossary, cfg_dir


def _resolve_source(args, cfg_dir: Path):
    """确定源文件与格式。

    优先级：命令行 --src > pipeline.yaml 声明 > 报错。
    这样日常使用不必带参数，而临时换源仍可覆盖。
    """
    if getattr(args, "src", None):
        return Path(args.src), getattr(args, "format", None) or "arb"
    pipe = load_pipeline(cfg_dir / "pipeline.yaml")
    if pipe is None:
        raise SystemExit(
            "未指定 --src，且 config/pipeline.yaml 未声明 source.path。\n"
            f"  请创建 {cfg_dir / 'pipeline.yaml'}，例如：\n"
            "  source:\n"
            "    path: ../lib/shared/l10n/arb/app_en.arb\n"
            "    format: arb"
        )
    fmt = getattr(args, "format", None) if getattr(args, "src", None) else None
    return pipe.source.path, (fmt or pipe.source.format)


def _resolve_locales(args, cfg_dir: Path) -> list[str]:
    if getattr(args, "locales", None):
        return list(args.locales)
    pipe = load_pipeline(cfg_dir / "pipeline.yaml")
    if pipe and pipe.locales:
        return list(pipe.locales)
    raise SystemExit(
        "未指定 --locales，且 config/pipeline.yaml 未声明 locales。"
    )


def cmd_add(args) -> int:
    """人工登记一条待处理记录 —— **只写收件箱，不碰产品文件**。

    这是开发者的唯一写入口。产品文件（app_en.arb 与各语言文件）由
    `pipeline ingest` 统一维护，避免并发冲突与来源混淆。
    """
    brief, glossary, cfg_dir = _load_config(args)
    pipe = load_pipeline(cfg_dir / "pipeline.yaml")
    if pipe is None:
        raise SystemExit("缺少 config/pipeline.yaml，无法确定收件箱位置")

    text = args.text
    if not text and args.stdin:
        text = sys.stdin.read().strip()
    if not text:
        raise SystemExit("请用 --text 提供内容，或用 --stdin 从管道读入")

    key = args.key or newsrc.suggest_key(text)
    if not args.key:
        print(f"未指定 --key，按内容推测为：{key}")
        print("  （推测可能不准，建议显式指定 --key）")

    # 查重：源侧查 en 源，译文侧查对应文件
    existing: set[str] = set()
    if args.locale:
        path = pipe.output.target_for(args.locale)
        if path.exists():
            from .adapters import sources as src_adapters

            try:
                existing = {e.key for e in src_adapters.get_adapter(pipe.source.format)(path)}
            except Exception:  # noqa: BLE001
                pass
    else:
        if pipe.source.path.exists():
            from .adapters import sources as src_adapters

            try:
                existing = {
                    e.key for e in src_adapters.get_adapter(pipe.source.format)(pipe.source.path)
                }
            except Exception:  # noqa: BLE001
                pass

    ok, msg = inbox.validate_new_item(key, text, existing, args.replace)
    if not ok and not args.force:
        print(f"✗ {msg}")
        print(f"  收件箱：{inbox.inbox_path_for(pipe)}")
        return 1

    item = inbox.InboxItem(
        key=key,
        text=text,
        locale=args.locale,
        description=args.description,
        replace=args.replace,
    )
    spec = brief.spec_for(args.locale) if args.locale else None
    warns = inbox.preview_warnings(item, glossary, spec.max_length if spec else None)

    box_path = inbox.inbox_path_for(pipe)
    if args.dry_run:
        print(f"✓ 校验通过（dry-run，未写入收件箱）")
    else:
        box = inbox.Inbox.load(box_path)
        box.append(item)
        print(f"✓ 已登记到收件箱 {box_path.name}（当前第 {len(box.items)} 条）")
    for w in warns:
        print(f"  · {w}")
    print("\n下一步：python -m pipeline ingest   # 由管线写入产品文件")
    return 0


def cmd_init(args) -> int:
    """创建收件箱文件（团队 clone 后的第一步）。"""
    _, _, cfg_dir = _load_config(args)
    pipe = load_pipeline(cfg_dir / "pipeline.yaml")
    if pipe is None:
        raise SystemExit("缺少 config/pipeline.yaml，无法确定收件箱位置")
    path = inbox.inbox_path_for(pipe)
    if path.exists() and path.stat().st_size:
        print(f"收件箱已存在：{path}")
        box = inbox.Inbox.load(path)
        print(f"当前 {len(box.items)} 条待处理")
        return 0
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(inbox.INBOX_HEADER, encoding="utf-8")
    print(f"✓ 已创建收件箱：{path}")
    print("\n人工只写这个文件。产品文件（app_*.arb）由管线维护，不要手工编辑。")
    print("  查看：python -m pipeline inbox")
    print("  落地：python -m pipeline ingest")
    return 0


def cmd_inbox(args) -> int:
    """查看收件箱待处理内容。"""
    _, _, cfg_dir = _load_config(args)
    pipe = load_pipeline(cfg_dir / "pipeline.yaml")
    if pipe is None:
        raise SystemExit("缺少 config/pipeline.yaml")
    path = inbox.inbox_path_for(pipe)
    box = inbox.Inbox.load(path)
    if not box.items and not box.malformed:
        print(f"收件箱为空：{path}")
        return 0
    print(f"收件箱 {path}：{len(box.items)} 条待处理")
    for n, it in enumerate(box.items, start=1):
        loc = it.locale or "en(源)"
        print(f"  {n}. [{loc:<12}] {it.key} = {it.text[:44]!r}")
    for ln, err in box.malformed:
        print(f"  ⚠ 第 {ln} 行格式错误：{err}")
    if not box.items and not box.malformed:
        print("  （空）直接在此文件追加一行 JSON 即可，或用 pipeline add")
    return 0


def cmd_ingest(args) -> int:
    """把收件箱内容写入产品文件 —— 唯一动产品文件的入口。

    去重：先在 en 源里找等价 key，命中则丢弃待翻译项并把代码引用改指向已有 key。
    """
    brief, glossary, cfg_dir = _load_config(args)
    pipe = load_pipeline(cfg_dir / "pipeline.yaml")
    if pipe is None:
        raise SystemExit("缺少 config/pipeline.yaml")

    box_path = inbox.inbox_path_for(pipe)
    box = inbox.Inbox.load(box_path)
    if not box.items:
        print(f"收件箱为空，无需 ingest：{box_path}")
        for ln, err in box.malformed:
            print(f"  ⚠ 第 {ln} 行格式错误：{err}")
        return 0
    if box.malformed and not args.force:
        print(f"✗ 收件箱有 {len(box.malformed)} 行格式错误，先修好再 ingest（或 --force 跳过）：")
        for ln, err in box.malformed:
            print(f"  第 {ln} 行：{err}")
        return 1

    # ---- 1  去重：en 里已有等价 key 就复用 ----
    from .adapters import sources as src_adapters

    existing_entries = (
        src_adapters.get_adapter(pipe.source.format)(pipe.source.path)
        if pipe.source.path.exists()
        else []
    )
    dedup = dedup_stage.find_matches(box.items, existing_entries, args.fuzzy_threshold)
    valid_keys = dedup_stage.collect_valid_keys(existing_entries)

    dup_items = {m.item_key for m in dedup.dups}
    fuzzy_items = {m.item_key for m in dedup.candidates}

    if dedup.dups or dedup.candidates:
        print(f"去重检查：{len(dedup.dups)} 条重复，{len(dedup.candidates)} 条疑似")
        for m in dedup.candidates:
            tag = "重复" if m.is_dup else "疑似(需人工确认)"
            print(
                f"  · [{tag}] {m.item_key} = {m.item_text[:34]!r}"
                f"≈ 已有 {m.existing_key} = {m.existing_text[:28]!r}"
                f"（{m.level} {m.score}）"
            )

    if dedup.candidates and not args.force and fuzzy_items and not args.accept_fuzzy:
        print(
            f"\n✗ 有 {len(fuzzy_items)} 条疑似重复需人工判定。\n"
            f"  确认可合并 → 加 --accept-fuzzy（会复用已有 key）\n"
            f"  确认是新文案 → 先改写文案措辞再重试"
        )
        return 1

    # ---- 2  落地 ----
    print(f"\ningest {len(box.items) - len(dup_items)} 条 from {box_path.name}")
    consumed: list[int] = []
    failed = 0
    ordered = sorted(
        (it for it in box.items if it.key not in dup_items),
        key=lambda it: (not it.is_source, it.line_no),
    )

    for it in ordered:
        if it.is_source:
            result = newsrc.add_entry(
                pipe, it.key, it.text, glossary,
                description=it.description,
                dry_run=args.dry_run,
                allow_overwrite=it.replace,
            )
        else:
            result = newsrc.set_translation(
                pipe, it.locale, it.key, it.text, glossary, brief,
                dry_run=args.dry_run,
                allow_overwrite=it.replace,
            )
        if result.ok:
            consumed.append(it.line_no)
            tag = "源" if it.is_source else it.locale
            print(f"  ✓ [{tag}] {it.key}")
            for w in result.warnings:
                print(f"      · {w}")
        else:
            failed += 1
            print(f"  ✗ {it.key}：{result.message}")

    # ---- 3  重复项：改写代码引用指向已有 key，然后出箱 ----
    if dedup.dups:
        print(f"\n重复项处理（{len(dedup.dups)} 条）：复用已有 key，不新增")
        scan_roots = _scan_roots(cfg_dir)
        for m in dedup.dups:
            if not m.existing_key:
                continue
            # 收件箱里该 key 自身的引用无需改写（它是新增的，未落地）
            rws = dedup_stage.rewrite_references(
                scan_roots, m.item_key, m.existing_key, valid_keys,
                dry_run=args.dry_run or not args.apply_refs,
            )
            if rws:
                loc = f"{len(rws)} 处" if args.apply_refs and not args.dry_run else f"{len(rws)} 处(dry-run)"
                print(f"  → {m.item_key} ⇒ {m.existing_key}：代码引用 {loc}")
                for rw in rws[:2]:
                    print(f"      {rw.file}:{rw.line_no}")
                if len(rws) > 2:
                    print(f"      …另有 {len(rws) - 2} 处")
            else:
                print(f"  → {m.item_key} ⇒ {m.existing_key}：代码中无引用")
            valid_keys.add(m.existing_key)
            consumed.append(_line_of(box, m.item_key))

    if args.dry_run:
        print("\n(dry-run，未清理收件箱)")
        return 1 if failed else 0

    if consumed and not args.keep:
        box.clear(sorted(set(consumed)))
        print(f"\n已清理 {len(set(consumed))} 条已处理记录")
    elif consumed:
        print(f"\n(--keep：{len(set(consumed))} 条记录保留在收件箱)")

    if failed:
        print(f"\n{failed} 条失败，保留在收件箱中待修正")
        return 1
    print("\n下一步：python -m pipeline run   # 翻译到各语言并出报告")
    return 0


def _line_of(box: inbox.Inbox, key: str) -> int:
    for it in box.items:
        if it.key == key:
            return it.line_no
    return -1


def _scan_roots(cfg_dir: Path) -> list[Path]:
    """代码扫描根：从源文件往上找到仓库根，再取其下的源码目录。"""
    pipe = load_pipeline(cfg_dir / "pipeline.yaml")
    if pipe is None:
        return []
    proj_root = pipe.source.path.parent
    while proj_root.parent != proj_root:
        if (proj_root / "pubspec.yaml").exists() or (proj_root / "lib").exists():
            break
        proj_root = proj_root.parent
    for name in ("lib", "src"):
        p = proj_root / name
        if p.exists():
            return [p]
    return []


def _clear_inbox(
    pipe,
    entries: list,
    by_locale: dict[str, list[Translation]],
    locales: list[str],
) -> int:
    """清除收件箱里"已翻译完"的条目。

    判定条件（全部满足才清）：
      1. key 已在 en 源里落地（源侧已 ingest）
      2. 该 key 在**所有**目标语言都有非 fallback 的译文
         —— 有任何一档还落回英文，就说明没翻完，留箱里等人处理

    这样收件箱里剩下的永远是"还没搞定的东西"，可以直接当待办清单用。
    """
    from .models import Entry  # noqa: F401  (类型可读性)

    box_path = inbox.inbox_path_for(pipe)
    box = inbox.Inbox.load(box_path)
    if not box.items:
        return 0

    # 已落地的 key（源侧）
    landed = {e.key for e in entries}

    # 各语言的完成情况
    done_keys: set[str] = set()
    for loc in locales:
        for tr in by_locale.get(loc, []):
            if tr.origin == "fallback_en":
                continue
            done_keys.add(tr.key)

    cleared: list[int] = []
    for it in box.items:
        if it.key not in landed:
            continue  # 源侧还没落地
        if it.key not in done_keys:
            continue  # 还有语言没翻完
        cleared.append(it.line_no)

    if cleared:
        box.clear(cleared)
    return len(cleared)


def _collect_existing(out_dir: Path, fmt: str, locales: list[str], target_for) -> dict:
    """读现有产物里已有的译文（用于 --only-missing 与增量）。"""
    import json as _json

    out: dict[str, dict[str, str]] = {}
    for loc in locales:
        p = target_for(loc)
        if not p.exists():
            continue
        try:
            data = _json.loads(p.read_text(encoding="utf-8-sig"))
        except Exception:  # noqa: BLE001
            continue
        out[loc] = {
            k: v for k, v in data.items()
            if not k.startswith("@") and isinstance(v, str)
        }
    return out


def cmd_batch(args) -> int:
    """agent 模式：导出待翻译清单 / 回填并落地。无需 API key。"""
    from .stages import agentmode

    brief, glossary, cfg_dir = _load_config(args)
    src, fmt = _resolve_source(args, cfg_dir)
    locales = _resolve_locales(args, cfg_dir)
    pipe = load_pipeline(cfg_dir / "pipeline.yaml")

    out_dir = Path(args.out) if args.out else (pipe.output.dir if pipe else src.parent / "out")
    target_for = (
        pipe.output.target_for if pipe
        else (lambda loc: out_dir / f"app_{loc}.arb")
    )
    manifest_path = (
        Path(args.manifest) if args.manifest else out_dir / "translate-tasks.json"
    )

    entries = source_adapters.get_adapter(fmt)(src)
    entry_map = {e.key: e for e in entries}

    # ---------------- export ----------------
    if args.mode == "export":
        existing = _collect_existing(out_dir, fmt, locales, target_for)
        man = agentmode.export(
            entries, locales, brief, glossary,
            only_missing=args.only_missing,
            existing=existing,
        )
        agentmode.write_manifest(manifest_path, man)
        print(f"已导出 {len(man.tasks)} 条待翻译任务 → {manifest_path}")
        by_loc = man.by_locale()
        for loc, ts in by_loc.items():
            print(f"  {loc}: {len(ts)} 条")
        print(
            "\n填好每条的 translation 字段后：\n"
            f"  python -m pipeline batch import --manifest {manifest_path}"
        )
        return 0

    # ---------------- import ----------------
    if not manifest_path.exists():
        raise SystemExit(
            f"清单不存在：{manifest_path}\n先跑：python -m pipeline batch export"
        )
    man = agentmode.read_manifest(manifest_path)

    missing = man.unfilled()
    if missing:
        print(f"✗ 清单里有 {len(missing)} 条 translation 为空，无法落地：")
        for t in missing[:10]:
            print(f"    {t.key} [{t.locale}] {t.source[:44]!r}")
        if len(missing) > 10:
            print(f"    …另有 {len(missing) - 10} 条")
        print(f"\n清单：{manifest_path}")
        return 1

    # 逐条过 QA 闸门 —— 与 run 走完全相同的检查
    all_issues: list[QAIssue] = []
    by_locale: dict[str, list[Translation]] = {}
    tm_similar: set[tuple[str, str]] = set()

    for loc, ts in man.by_locale().items():
        trs: list[Translation] = []
        for t in ts:
            entry = entry_map.get(t.key)
            if entry is None:
                all_issues.append(
                    QAIssue("orphan_key", loc, t.key, "清单里的 key 在源文件中不存在")
                )
                continue
            tr = Translation(
                key=t.key, target=t.translation, locale=loc,
                origin="human",  # agent/人工产出，纳入复查清单
                glossary_terms=tuple(x.split(" ")[0] for x in t.hit_terms),
                source_hash=entry.source_hash,
            )
            trs.append(tr)
            all_issues.extend(qa.check_entry(entry, tr, brief, glossary))
        by_locale[loc] = trs

    if len(by_locale) > 1:
        all_issues.extend(qa.cross_locale_consistency(by_locale, glossary))

    review_items = review.build_review(
        source_by_key={e.key: e.source for e in entries},
        by_locale=by_locale, brief=brief, glossary=glossary,
        tm_similar_keys=tm_similar,
    )

    report = BatchReport(total=len(man.tasks))
    report.llm = len(man.tasks)
    report.blocking_issues = sum(1 for i in all_issues if i.blocking)
    report.warnings = sum(1 for i in all_issues if not i.blocking)

    rc = _print_issues(all_issues)
    review.print_summary(review_items, report.as_dict(), locales)
    review.write_report(
        out_dir / "report.json", review_items, report.as_dict(), all_issues, locales
    )

    if rc != 0:
        print("\n质检未通过，产物未写出（阻断）。清单保留，修好后再 import")
        return 2

    # 写产物：保留清单里没提到的既有 key
    for loc, ts in man.by_locale().items():
        path = target_for(loc)
        merged: dict[str, str] = {}
        if path.exists():
            import json as _json

            data = _json.loads(path.read_text(encoding="utf-8-sig"))
            merged = {
                k: v for k, v in data.items()
                if not k.startswith("@") and isinstance(v, str)
            }
        for t in ts:
            merged[t.key] = t.translation
        # 关键：write_arb 按 entry 列表筛选输出，必须给**完整**源条目列表，
        # 否则 merged 里不在本批的 key 会被静默丢弃（曾导致 126 条只剩 1 条）。
        emit.write_arb(
            path, entries, merged, loc,
            arb_locale=(pipe.output.arb_locale_for(loc) if pipe else loc),
        )
        print(f"  ✓ {loc}: 更新 {len(ts)} 条 → {path.name}")

    print(f"\n已落地 {len(man.tasks)} 条译文。复查清单见 {out_dir / 'report.json'}")
    return 0


def cmd_extract(args) -> int:
    brief, glossary, cfg_dir = _load_config(args)
    src, fmt = _resolve_source(args, cfg_dir)
    entries = source_adapters.get_adapter(fmt)(src)
    print(f"抽取 {len(entries)} 条 from {src} (format={fmt})")
    for e in entries:
        ph = f" {{{','.join(e.placeholders)}}}" if e.placeholders else ""
        desc = f"  # {e.description}" if e.description else ""
        print(f"  {e.key}{ph}{desc}")
    hits = sum(1 for e in entries if glossary.match_in(e.source))
    print(f"\n其中 {hits} 条命中术语表（共 {len(glossary.terms)} 条术语）")
    return 0


def cmd_qa(args) -> int:
    """只跑质检：拿已有产物与源比对，不调用 LLM。CI 里用这个。"""
    import json

    brief, glossary, cfg_dir = _load_config(args)
    src, fmt = _resolve_source(args, cfg_dir)
    entries = source_adapters.get_adapter(fmt)(src)
    entry_map = {e.key: e for e in entries}

    products = list(getattr(args, "products", None) or [])
    if not products:
        pipe = load_pipeline(cfg_dir / "pipeline.yaml")
        if pipe:
            products = [str(pipe.output.target_for(loc)) for loc in pipe.locales]
    if not products:
        raise SystemExit("未指定 --products，且 config/pipeline.yaml 未声明输出位置")

    all_issues: list[QAIssue] = []
    by_locale: dict[str, list[Translation]] = {}
    for prod in products:
        p = Path(prod)
        if not p.exists():
            print(f"跳过不存在的产物: {p}")
            continue
        data = json.loads(p.read_text(encoding="utf-8-sig"))
        locale = data.get("@@locale", p.stem)
        trs = [
            Translation(key=k, target=v, locale=locale, origin="human")
            for k, v in data.items()
            if not k.startswith("@") and isinstance(v, str)
        ]
        by_locale.setdefault(locale, []).extend(trs)
        all_issues.extend(qa.check_batch(entry_map, trs, brief, glossary))

    if len(by_locale) > 1:
        all_issues.extend(qa.cross_locale_consistency(by_locale, glossary))

    return _print_issues(all_issues)


def cmd_run(args) -> int:
    brief, glossary, cfg_dir = _load_config(args)
    src, fmt = _resolve_source(args, cfg_dir)
    locales = _resolve_locales(args, cfg_dir)
    pipe = load_pipeline(cfg_dir / "pipeline.yaml")

    # 输出位置：--out > pipeline.yaml 声明 > 源文件旁的 out/
    if getattr(args, "out", None):
        out_dir = Path(args.out)
        target_for = lambda loc: out_dir / f"app_{loc}.arb"  # noqa: E731
        baseline_for = lambda loc: DEFAULT_CACHE / "baseline" / f"{loc}.json"  # noqa: E731
    elif pipe:
        out_dir = pipe.output.dir
        target_for = pipe.output.target_for
        baseline_for = pipe.baseline_path
    else:
        out_dir = src.parent / "out"
        target_for = lambda loc: out_dir / f"app_{loc}.arb"  # noqa: E731
        baseline_for = lambda loc: DEFAULT_CACHE / "baseline" / f"{loc}.json"  # noqa: E731

    provider_kind = getattr(args, "provider", None) or (pipe.provider if pipe else "mock")
    tm_path = (pipe.tm_path if pipe else None) or (DEFAULT_CACHE / "tm.json")

    # 1 提取
    entries = source_adapters.get_adapter(fmt)(src)
    entry_map = {e.key: e for e in entries}
    print(f"[1/7] 提取 {len(entries)} 条 from {src}")

    provider = translate.get_provider(provider_kind, glossary)
    memory = tm_stage.TranslationMemory(tm_path).load()

    all_issues: list[QAIssue] = []
    all_by_locale: dict[str, list[Translation]] = {}
    report = BatchReport(total=len(entries))
    tm_similar: set[tuple[str, str]] = set()

    for locale in locales:
        # 2 增量
        base_file = baseline_for(locale)
        baseline = emit.load_baseline(base_file, locale)
        plans = diff_stage.diff(
            entries, baseline, glossary.version, brief.version, locale
        )
        needs = [p.entry for p in plans if p.needs_translation]
        reused = [p for p in plans if p.kind == diff_stage.ChangeKind.UNCHANGED]
        print(
            f"  · {locale}: 需翻译 {len(needs)} / 复用 {len(reused)} / 共 {len(plans)}"
        )

        # 3 TM 检索：命中即免翻，未命中的才进 LLM
        still_need: list = []
        trs: list[Translation] = []
        tm_hits = 0
        for plan in plans:
            if not plan.needs_translation:
                trs.append(plan.reusable)  # type: ignore[arg-type]
                continue
            hit = memory.lookup(plan.entry.source, locale)
            target = hit.record.translations.get(locale) if hit.hit and hit.record else None
            if target:
                tm_hits += 1
                if hit.kind == "similar":
                    tm_similar.add((locale, plan.entry.key))
                trs.append(
                    Translation(
                        key=plan.entry.key,
                        target=target,
                        locale=locale,
                        origin="tm_hit",
                        provider="tm",
                        source_hash=plan.entry.source_hash,
                        note=f"{hit.kind}@{hit.score}",
                    )
                )
                continue
            still_need.append(plan.entry)
        print(f"    TM 命中 {tm_hits} 条，待翻译 {len(still_need)} 条")

        # 4+5 装配 + 翻译
        if still_need:
            trs.extend(
                translate.translate_entries(
                    still_need, locale, brief, glossary, provider, memory
                )
            )
        report.tm_hit += sum(1 for t in trs if t.origin == "tm_hit")
        report.llm += sum(1 for t in trs if t.origin == "llm")
        report.unchanged += len(reused)

        # Fallback：缺译文回落 en
        trs, n_fb = emit.apply_fallback(entries, trs, "en")
        report.fallback_en += n_fb

        all_by_locale[locale] = trs
        all_issues.extend(qa.check_batch(entry_map, trs, brief, glossary))

    # 跨语言一致性
    if len(locales) > 1:
        all_issues.extend(qa.cross_locale_consistency(all_by_locale, glossary))

    report.blocking_issues = sum(1 for i in all_issues if i.blocking)
    report.warnings = sum(1 for i in all_issues if not i.blocking)
    if isinstance(provider, translate.OpenAICompatProvider):
        report.tokens_in = provider.tokens_in
        report.tokens_out = provider.tokens_out

    # 4 复查清单：机械闸门管不到的语义正确性
    review_items = review.build_review(
        source_by_key={e.key: e.source for e in entries},
        by_locale=all_by_locale,
        brief=brief,
        glossary=glossary,
        tm_similar_keys=tm_similar,
    )

    rc = _print_issues(all_issues)
    review.print_summary(review_items, report.as_dict(), locales)
    review.write_report(out_dir / "report.json", review_items, report.as_dict(), all_issues, locales)

    if rc != 0:
        print("\n质检未通过，产物未写出（阻断）。复查清单已写入 report.json")
        return 2

    # 7 写出
    for locale, trs in all_by_locale.items():
        targets = {t.key: t.target for t in trs}
        target_path = target_for(locale)
        if fmt == "arb":
            emit.write_arb(
                target_path, entries, targets, locale,
                arb_locale=(pipe.output.arb_locale_for(locale) if pipe else locale),
            )
        elif fmt == "json":
            emit.write_json(target_path, entries, targets, locale)
        else:
            emit.write_key_value(target_path, entries, targets, locale)
        emit.write_baseline(
            baseline_for(locale),
            entries, trs, locale, glossary.version, brief.version,
        )
        emit.commit_tm(memory, entries, trs, approved=getattr(args, "approve", False))

    # 8 清除收件箱里「已翻译完」的条目
    cleared = _clear_inbox(pipe, entries, all_by_locale, locales)
    if cleared:
        print(f"\n已清除收件箱 {cleared} 条翻译完的条目")

    print(f"\n产物已写入 {out_dir}")
    for path in sorted(out_dir.glob("*")):
        if path.suffix in (".arb", ".json", ".txt"):
            print(f"  {path.name}")
    print("  " + "  ".join(f"{k}={v}" for k, v in report.as_dict().items()))
    return 0


def cmd_tm(args) -> int:
    _, _, cfg_dir = _load_config(args)
    pipe = load_pipeline(cfg_dir / "pipeline.yaml")
    tm_path = (pipe.tm_path if pipe else None) or (DEFAULT_CACHE / "tm.json")
    memory = tm_stage.TranslationMemory(tm_path).load()
    stats = memory.stats()
    for k, v in stats.items():
        print(f"{k}: {v}")
    if args.list:
        for r in sorted(memory.records.values(), key=lambda x: x.source_hash)[: args.limit]:
            mark = "✓" if r.approved else "·"
            print(f"  {mark} {r.source[:60]!r} -> {list(r.translations.items())}")
    return 0


def cmd_glossary(args) -> int:
    """校验术语表自洽性，并列出各 locale 的标准译法矩阵。"""
    _, glossary, _ = _load_config(args)
    print(f"术语 {len(glossary.terms)} 条  version={glossary.version}")
    if glossary.conflicts:
        print(f"\n=== 自洽性冲突 {len(glossary.conflicts)} 处（应先修术语表再跑管线）===")
        for c in glossary.conflicts:
            print(f"  - {c}")
    else:
        print("自洽性检查通过：无冲突")

    locales = sorted({k for t in glossary.terms for k in t.translations})
    if args.matrix:
        print("\n| term | " + " | ".join(locales) + " | forbidden |")
        print("|---" * (len(locales) + 2) + "|")
        for t in sorted(glossary.terms, key=lambda x: x.term):
            forb = ";".join(
                f"{k}:{','.join(v)}" for k, v in sorted(t.forbidden_by_locale.items())
            ) + (";".join(t.forbidden) if t.forbidden else "")
            cells = " | ".join(t.translation_for(loc) or "—" for loc in locales)
            print(f"| {t.term} | {cells} | {forb or '—'} |")
    return 2 if glossary.conflicts else 0


def _print_issues(issues: list[QAIssue]) -> int:
    if not issues:
        print("质检通过：无问题")
        return 0
    blocking = [i for i in issues if i.blocking]
    warns = [i for i in issues if not i.blocking]
    if blocking:
        print(f"\n=== BLOCKING {len(blocking)} 条 ===")
        for i in blocking:
            print(f"  {i}")
    if warns:
        print(f"\n=== WARN {len(warns)} 条 ===")
        for i in warns:
            print(f"  {i}")
    return 2 if blocking else 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        prog="pipeline",
        description="多语言翻译管线（源与产物位置由 config/pipeline.yaml 声明）",
    )
    sub = ap.add_subparsers(dest="cmd", required=True)
    FORMATS = ["arb", "json", "csv", "po", "md"]

    def add_config(p):
        p.add_argument("--config", help="配置目录（含 pipeline.yaml / brief.yaml / glossary.csv）")

    def add_src(p, required=False):
        p.add_argument("--src", required=required, help="源文件（默认取 pipeline.yaml 的 source.path）")
        p.add_argument("--format", choices=FORMATS, help="源格式（默认取 pipeline.yaml 的 source.format）")
        add_config(p)

    # 人工入口：登记待处理记录（只写收件箱）
    p = sub.add_parser("add", help="登记一条待处理记录（只写收件箱，不碰产品文件）")
    p.add_argument("--key", help="key（lowerCamelCase）；省略则按 text 推测")
    p.add_argument("--text", help="内容。省略 --locale 时为 en 源文案，否则为该语言的译文")
    p.add_argument("--stdin", action="store_true", help="从标准输入读内容")
    p.add_argument("--locale", help="目标语言；省略表示写 en 源")
    p.add_argument("--description", help="上下文说明，喂给翻译模型做消歧")
    p.add_argument("--replace", action="store_true", help="允许覆盖已有 key")
    p.add_argument("--force", action="store_true", help="校验失败仍登记")
    p.add_argument("--dry-run", action="store_true", help="只校验不写入收件箱")
    add_config(p)
    p.set_defaults(func=cmd_add)

    p = sub.add_parser("init", help="创建收件箱文件（人工唯一该写的文件）")
    add_config(p)
    p.set_defaults(func=cmd_init)

    p = sub.add_parser("inbox", help="查看收件箱待处理内容")
    add_config(p)
    p.set_defaults(func=cmd_inbox)

    p = sub.add_parser("ingest", help="把收件箱写入产品文件（唯一动产品文件的入口）")
    p.add_argument("--dry-run", action="store_true", help="只校验不写入")
    p.add_argument("--keep", action="store_true", help="保留已处理的记录，不清理收件箱")
    p.add_argument("--force", action="store_true", help="忽略格式错误行 / 跳过疑似重复阻断")
    p.add_argument("--fuzzy-threshold", type=float, default=0.72,
                   help="疑似重复的相似度阈值（默认 0.85）")
    p.add_argument("--accept-fuzzy", action="store_true",
                   help="确认疑似重复也可合并（会复用已有 key）")
    p.add_argument("--apply-refs", action="store_true",
                   help="实际改写代码引用（默认只预览）")
    add_config(p)
    p.set_defaults(func=cmd_ingest)

    p = sub.add_parser("extract", help="只抽取，不翻译")
    add_src(p)
    p.set_defaults(func=cmd_extract)

    p = sub.add_parser("run", help="跑完整管线")
    add_src(p)
    p.add_argument("--locales", nargs="+", help="目标语言（默认取 pipeline.yaml 的 locales）")
    p.add_argument("--out", help="产物输出目录（默认取 pipeline.yaml 的 output.dir）")
    p.add_argument("--provider", choices=["mock", "dictionary", "openai"],
                   help="翻译后端：mock=占位/ dictionary=离线词典（链路验证） / openai=真实模型")
    p.add_argument("--approve", action="store_true",
                   help="把本批译文直接标记为人工审核通过")
    p.set_defaults(func=cmd_run)

    # ---- agent 模式：不依赖 API key ----
    p = sub.add_parser(
        "batch",
        help="agent 模式：导出待翻译清单 / 回填并落地（无需 API key）",
    )
    add_src(p)
    p.add_argument("mode", choices=["export", "import"],
                   help="export=导出待办清单 / import=回填清单并写产物")
    p.add_argument("--locales", nargs="+", help="目标语言（默认取 pipeline.yaml 的 locales）")
    p.add_argument("--out", help="产物输出目录")
    p.add_argument("--manifest", help="清单路径（默认 <产物目录>/translate-tasks.json）")
    p.add_argument("--only-missing", action="store_true",
                   help="export 时只导出现有产物里缺失的 key")
    p.set_defaults(func=cmd_batch)

    p = sub.add_parser("qa", help="只跑质检（CI 用）")
    add_src(p)
    p.add_argument("--products", nargs="+", help="待检产物（默认取 pipeline.yaml 声明的输出）")
    p.set_defaults(func=cmd_qa)

    p = sub.add_parser("tm", help="查看翻译记忆库")
    p.add_argument("--stats", action="store_true")
    p.add_argument("--list", action="store_true")
    p.add_argument("--limit", type=int, default=20)
    add_config(p)
    p.set_defaults(func=cmd_tm)

    p = sub.add_parser("glossary", help="校验术语表自洽性")
    add_config(p)
    p.add_argument("--matrix", action="store_true", help="打印译法矩阵")
    p.set_defaults(func=cmd_glossary)

    args = ap.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())