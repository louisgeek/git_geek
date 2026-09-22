import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git_geek/src/data/git_runner.dart';
import 'package:git_geek/src/data/git_url.dart';
import 'package:git_geek/src/l10n/strings.dart';
import 'package:git_geek/src/logic/git_log_parser.dart';
import 'package:git_geek/src/logic/git_tag_parser.dart';
import 'package:git_geek/src/models/git_commit.dart';
import 'package:git_geek/src/models/git_tag.dart';
import 'package:git_geek/src/state/controller.dart';

class GitTagPage extends ConsumerStatefulWidget {
  const GitTagPage({super.key});

  @override
  ConsumerState<GitTagPage> createState() => _GitTagPageState();
}

class _GitTagPageState extends ConsumerState<GitTagPage> {
  GitTagController get vm => ref.read(gitTagControllerProvider.notifier);
  Set<String> expandedNames = {};
  late bool showPaste;
  bool sortExpanded = false;
  bool showAbout = false;
  bool langExpanded = false;

  @override
  void initState() {
    super.initState();
    showPaste = !supportsNativeGit;
  }

  void toggleExpand(String name) {
    setState(() {
      if (expandedNames.contains(name)) {
        expandedNames = {...expandedNames}..remove(name);
      } else {
        expandedNames = {...expandedNames, name};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ui = ref.watch(gitTagControllerProvider);
    final t = strings(ui.lang);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 8),
              _buildTitle(context, ui, t),
              const SizedBox(height: 12),
              _buildRepoCard(context, ui, t),
              const SizedBox(height: 12),
              _buildStats(ui, t),
              const SizedBox(height: 12),
              _buildSearchSort(context, ui, t),
              const SizedBox(height: 12),
              _buildTabs(ui, t),
              const SizedBox(height: 12),
              ..._buildList(context, ui, t),
              const SizedBox(height: 12),
              _buildPasteCard(context, ui, t),
              const SizedBox(height: 16),
            ],
          ),
        ),
        if (showAbout) _buildAboutDialog(ui, t),
      ],
    );
  }

  Widget _buildTitle(BuildContext context, GitTagUiState ui, AppStrings t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('GitGeek',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            PopupMenuButton<AppLang>(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(ui.lang == AppLang.zh
                    ? '${t.langZh} ▾'
                    : '${t.langEn} ▾'),
              ),
              onSelected: vm.setLang,
              itemBuilder: (c) => [
                PopupMenuItem(
                    value: AppLang.zh, child: Text(t.langZh)),
                PopupMenuItem(
                    value: AppLang.en, child: Text(t.langEn)),
              ],
            ),
            TextButton(
                onPressed: () => setState(() => showAbout = true),
                child: Text(t.about)),
          ],
        ),
        Text(
          supportsNativeGit ? t.subtitleDesktop : t.subtitleNoGit,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildRepoCard(
      BuildContext context, GitTagUiState ui, AppStrings t) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.repoCardTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ClearableTextField(
              value: ui.repoPath,
              onChanged: vm.setRepoPath,
              label: t.repoPathLabel,
              placeholder: t.repoPathPlaceholder,
            ),
            if (GitUrlDetector.isRemoteUrl(ui.repoPath.trim())) ...[
              const SizedBox(height: 4),
              Text(t.remoteUrlHint,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                          color: Theme.of(context).colorScheme.primary)),
              if (ui.cacheDirHint.isNotBlank) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${t.cachePrefix}: ${ui.cacheDirHint}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _copy(context, ui.cacheDirHint, t),
                      child: Text(t.copy),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 8),
            ClearableTextField(
              value: ui.remote,
              onChanged: vm.setRemote,
              label: t.remoteNameLabel,
              placeholder: t.remoteNamePlaceholder,
            ),
            if (ui.remoteUrl.isNotBlank) ...[
              const SizedBox(height: 4),
              Text(
                '${ui.remote.isEmpty ? 'origin' : ui.remote}:  ${ui.remoteUrl}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (ui.submodules.isNotEmpty || ui.isLoadingSubmodules) ...[
              const SizedBox(height: 8),
              Text(
                '${t.scopePrefix}: ${ui.selectedScope.isEmpty ? t.mainRepo : ui.selectedScope}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: [
                  FilterChip(
                    selected: ui.selectedScope.isEmpty,
                    onSelected: (_) => vm.selectScope(''),
                    label: Text(t.mainRepo,
                        style: Theme.of(context).textTheme.labelSmall),
                  ),
                  for (final sub in ui.submodules)
                    FilterChip(
                      selected: ui.selectedScope == sub.path,
                      onSelected: (_) => vm.selectScope(sub.path),
                      label: Text(
                        _subChipLabel(ui, sub),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                ],
              ),
            ],
            if (ui.submoduleError != null)
              Text('${t.errSubmodulePrefix}: ${ui.submoduleError}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                          color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                    onPressed:
                        ui.isLoadingLocal ? null : () => vm.refreshLocal(),
                    child: Text(t.btnRefreshLocal)),
                FilledButton(
                    onPressed:
                        ui.isLoadingRemote ? null : () => vm.refreshRemote(),
                    child: Text(t.btnRefreshRemote)),
                OutlinedButton(
                    onPressed:
                        ui.isLoading ? null : () => vm.refreshAll(),
                    child: Text(t.btnRefreshAll)),
                OutlinedButton(
                    onPressed: () => vm.loadSample(),
                    child: Text(t.btnSample)),
                TextButton(
                    onPressed: () => vm.clearAll(),
                    child: Text(t.btnClear)),
              ],
            ),
            if (ui.isCloning) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ui.cloningInfo.isEmpty
                          ? t.cloningFallback
                          : ui.cloningInfo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ],
            if (ui.isLoading) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${ui.isLoadingLocal ? t.loadingLocal : ''}${ui.isLoadingRemote ? t.loadingRemote : ''}${ui.isLoadingCommits ? t.loadingCommits : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            if (ui.localError != null)
              Text('${t.errLocalPrefix}: ${ui.localError}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                          color: Theme.of(context).colorScheme.error)),
            if (ui.remoteError != null)
              Text('${t.errRemotePrefix}: ${ui.remoteError}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                          color: Theme.of(context).colorScheme.error)),
            if (ui.lastRefreshInfo.isNotBlank)
              Text(ui.lastRefreshInfo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  String _subChipLabel(GitTagUiState ui, GitSubmodule sub) {
    final buf = StringBuffer(sub.displayName);
    if (sub.shortSha != null) buf.write('  ${sub.shortSha}');
    if (sub.status != SubmoduleStatus.ok) {
      buf.write(' (${sub.status.label(ui.lang)})');
    }
    final branch = (ui.submoduleBranches[sub.path]?.trim().isNotEmpty ?? false)
        ? ui.submoduleBranches[sub.path]
        : sub.branch?.trim().isNotEmpty == true
            ? sub.branch
            : null;
    if (branch != null && branch.isNotEmpty) buf.write('  $branch');
    return buf.toString();
  }

  Widget _buildStats(GitTagUiState ui, AppStrings t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final e in [
              (t.statLocal, ui.stats.localCount),
              (t.statRemote, ui.stats.remoteCount),
              (t.statSynced, ui.stats.syncedCount),
              (t.statOnlyLocal, ui.stats.onlyLocalCount),
              (t.statOnlyRemote, ui.stats.onlyRemoteCount),
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: StatCard(label: e.$1, count: e.$2),
                ),
              ),
          ],
        ),
        if (ui.stats.divergedCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              t.divergedWarn(ui.stats.divergedCount),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchSort(
      BuildContext context, GitTagUiState ui, AppStrings t) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ClearableTextField(
                value: ui.searchQuery,
                onChanged: vm.setSearch,
                label: t.searchTagLabel,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<TagSortMode>(
                value: ui.sortMode,
                decoration: InputDecoration(
                  labelText: t.sortLabel,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                items: TagSortMode.values
                    .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m.label(ui.lang),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall)))
                    .toList(),
                onChanged: (m) {
                  if (m != null) vm.setSort(m);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: TagFilter.values.map((f) {
            final count = switch (f) {
              TagFilter.all => ui.allCompare.length,
              TagFilter.synced => ui.stats.syncedCount,
              TagFilter.onlyLocal => ui.stats.onlyLocalCount,
              TagFilter.onlyRemote => ui.stats.onlyRemoteCount,
              TagFilter.diverged => ui.stats.divergedCount,
            };
            return FilterChip(
              selected: ui.filter == f,
              onSelected: (_) => vm.setFilter(f),
              label: Text('${f.label(ui.lang)}($count)'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTabs(GitTagUiState ui, AppStrings t) {
    return DefaultTabController(
      length: 4,
      initialIndex: ui.selectedTab.clamp(0, 3),
      child: Builder(
        builder: (context) {
          final ctrl = DefaultTabController.of(context);
          if (ctrl.index != ui.selectedTab.clamp(0, 3)) {
            // 同步外部 selectedTab（避免 setState 循环，用 microtask）
            Future.microtask(() {
              if (ctrl.index != ui.selectedTab.clamp(0, 3)) {
                ctrl.animateTo(ui.selectedTab.clamp(0, 3));
              }
            });
          }
          return TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            onTap: vm.setTab,
            tabs: [
              Tab(text: '${t.tabCompare}(${ui.visibleCompare.length})'),
              Tab(text: '${t.statLocal}(${ui.visibleLocal.length})'),
              Tab(text: '${t.statRemote}(${ui.visibleRemote.length})'),
              Tab(text: '${t.tabCommits}(${ui.visibleCommits.length})'),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildList(
      BuildContext context, GitTagUiState ui, AppStrings t) {
    switch (ui.selectedTab) {
      case 0:
        if (ui.visibleCompare.isEmpty) {
          return [EmptyHint(text: t.emptyCompare)];
        }
        return ui.visibleCompare
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CompareRow(
                    item: item,
                    t: t,
                    lang: ui.lang,
                    expanded:
                        expandedNames.contains('c-${item.name}'),
                    onToggle: () => toggleExpand('c-${item.name}'),
                    onViewCommit: () => vm.viewCommitForTag(item),
                  ),
                ))
            .toList();
      case 1:
        if (ui.visibleLocal.isEmpty) {
          return [EmptyHint(text: t.emptyLocalTab)];
        }
        return ui.visibleLocal
            .map((tag) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SimpleTagRow(
                    tag: tag,
                    t: t,
                    sideLabel: t.statLocal,
                    expanded:
                        expandedNames.contains('l-${tag.name}'),
                    onToggle: () => toggleExpand('l-${tag.name}'),
                  ),
                ))
            .toList();
      case 2:
        if (ui.visibleRemote.isEmpty) {
          return [EmptyHint(text: t.emptyRemoteTab)];
        }
        return ui.visibleRemote
            .map((tag) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SimpleTagRow(
                    tag: tag,
                    t: t,
                    sideLabel: t.statRemote,
                    expanded:
                        expandedNames.contains('r-${tag.name}'),
                    onToggle: () => toggleExpand('r-${tag.name}'),
                  ),
                ))
            .toList();
      default:
        final widgets = <Widget>[
          _buildCommitControlCard(context, ui, t),
          const SizedBox(height: 8),
        ];
        if (ui.visibleCommits.isEmpty) {
          widgets.add(EmptyHint(text: t.emptyCommits));
        } else {
          for (final c in ui.visibleCommits) {
            widgets.add(Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CommitRow(
                commit: c,
                t: t,
                onTagClick: vm.viewTagFromCommit,
                onSubmoduleClick: vm.viewSubmoduleChange,
                onCopy: (v) => _copy(context, v, t),
              ),
            ));
          }
        }
        return widgets;
    }
  }

  Widget _buildCommitControlCard(
      BuildContext context, GitTagUiState ui, AppStrings t) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${t.currentScopePrefix}: ${ui.selectedScope.isEmpty ? t.mainRepo : '${t.submoduleWord} ${ui.selectedScope}'}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            ClearableTextField(
              value: ui.commitQuery,
              onChanged: vm.setCommitQuery,
              label: t.searchCommitLabel,
            ),
            if (ui.branches.isNotEmpty || ui.isLoadingBranches) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  FilterChip(
                    selected: ui.branch.isEmpty,
                    onSelected: (_) => vm.selectBranch(''),
                    label: Text(t.currentBranchChip,
                        style:
                            Theme.of(context).textTheme.labelSmall),
                  ),
                  FilterChip(
                    selected: ui.branch == '--all',
                    onSelected: (_) => vm.selectBranch('--all'),
                    label: Text('--all',
                        style:
                            Theme.of(context).textTheme.labelSmall),
                  ),
                  for (final b in ui.branches)
                    FilterChip(
                      selected: ui.branch == b.name ||
                          (ui.branch.isEmpty && b.isCurrent),
                      onSelected: (_) => vm.selectBranch(b.name),
                      label: Text(
                          '${b.isCurrent ? '* ' : ''}${b.name}',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall),
                    ),
                ],
              ),
            ],
            if (ui.branchError != null)
              Text('${t.errBranchPrefix}: ${ui.branchError}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                          color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClearableTextField(
                    value: ui.branch,
                    onChanged: vm.setBranch,
                    label: t.branchLabel,
                    placeholder: t.branchPlaceholder,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: ClearableTextField(
                    value: ui.commitLimit,
                    onChanged: vm.setCommitLimit,
                    label: t.limitLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                    onPressed: ui.isLoadingCommits
                        ? null
                        : () => vm.refreshCommits(),
                    child: Text(t.btnRefreshCommits)),
                FilterChip(
                  selected: ui.commitNewestFirst,
                  onSelected: (_) => vm.toggleCommitOrder(),
                  label: Text(ui.commitNewestFirst
                      ? t.newestFirst
                      : t.oldestFirst),
                ),
              ],
            ),
            if (ui.isLoadingCommits) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 8),
                  Text(t.loadingCommitsLong,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
            if (ui.commitError != null)
              Text('${t.errCommitPrefix}: ${ui.commitError}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                          color: Theme.of(context).colorScheme.error)),
          ],
        ),
      ),
    );
  }

  Widget _buildPasteCard(
      BuildContext context, GitTagUiState ui, AppStrings t) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(t.pasteTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                TextButton(
                    onPressed: () =>
                        setState(() => showPaste = !showPaste),
                    child:
                        Text(showPaste ? t.collapse : t.expand)),
              ],
            ),
            if (showPaste) ...[
              Text(t.pasteTagDesc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant)),
              const SizedBox(height: 8),
              ClearableTextField(
                value: ui.localPaste,
                onChanged: vm.setLocalPaste,
                label: t.localPasteLabel,
                placeholder: t.localPastePlaceholder,
                minLines: 3,
              ),
              const SizedBox(height: 4),
              OutlinedButton(
                  onPressed: () => vm.parseLocalPaste(),
                  child: Text(
                      '${t.parseLocalPaste}(${GitTagParser.parseLocal(ui.localPaste).length} ${t.previewWord})')),
              const SizedBox(height: 8),
              ClearableTextField(
                value: ui.remotePaste,
                onChanged: vm.setRemotePaste,
                label: t.remotePasteLabel,
                placeholder: t.remotePastePlaceholder,
                minLines: 3,
              ),
              const SizedBox(height: 4),
              OutlinedButton(
                  onPressed: () => vm.parseRemotePaste(),
                  child: Text(
                      '${t.parseRemotePaste}(${GitTagParser.parseRemote(ui.remotePaste).length} ${t.previewWord})')),
              const SizedBox(height: 8),
              Text(t.pasteCommitDesc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant)),
              SelectableText(
                gitLogPasteCommand(ui.lang),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 8),
              ClearableTextField(
                value: ui.commitPaste,
                onChanged: vm.setCommitPaste,
                label: t.commitPasteLabel,
                placeholder: t.commitPastePlaceholder,
                minLines: 3,
              ),
              const SizedBox(height: 4),
              OutlinedButton(
                  onPressed: () => vm.parseCommitPaste(),
                  child: Text(
                      '${t.parseCommitPaste}(${GitLogParser.parse(ui.commitPaste).length} ${t.previewWord})')),
              const SizedBox(height: 8),
              ClearableTextField(
                value: ui.branchPaste,
                onChanged: vm.setBranchPaste,
                label: t.branchPasteLabel,
                placeholder: t.branchPastePlaceholder,
                minLines: 2,
              ),
              const SizedBox(height: 4),
              OutlinedButton(
                  onPressed: () => vm.parseBranchPaste(),
                  child: Text(
                      '${t.parseBranchPaste}(${GitLogParser.parseBranches(ui.branchPaste).length} ${t.previewWord})')),
              const SizedBox(height: 8),
              ClearableTextField(
                value: ui.submodulePaste,
                onChanged: vm.setSubmodulePaste,
                label: t.submodulePasteLabel,
                placeholder: t.submodulePastePlaceholder,
                minLines: 2,
              ),
              const SizedBox(height: 4),
              OutlinedButton(
                  onPressed: () => vm.parseSubmodulePaste(),
                  child: Text(
                      '${t.parseSubmodulePaste}(${GitSubmoduleParser.parse(ui.submodulePaste).length} ${t.previewWord})')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutDialog(GitTagUiState ui, AppStrings t) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.aboutTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('${t.aboutVersionLabel} $appVersion'),
                Text(t.aboutCopyright,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () =>
                          setState(() => showAbout = false),
                      child: Text(t.close)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copy(BuildContext context, String value, AppStrings t) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t.copied)));
  }
}

class ClearableTextField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final String? placeholder;
  final int minLines;
  const ClearableTextField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.placeholder,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _FieldController(value),
      onChanged: onChanged,
      minLines: minLines,
      maxLines: minLines <= 1 ? 1 : 8,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: value.isEmpty
            ? null
            : IconButton(
                icon: const Text('×'),
                onPressed: () => onChanged(''),
              ),
      ),
    );
  }
}

/// 轻量受控输入：每次 value 变化重建 controller 并保持光标在末尾
class _FieldController extends TextEditingController {
  _FieldController(String text) {
    this.text = text;
    selection = TextSelection.collapsed(offset: this.text.length);
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final int count;
  const StatCard({super.key, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text('$count',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final TagSyncStatus status;
  final AppStrings t;
  const StatusBadge({super.key, required this.status, required this.t});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      TagSyncStatus.synced => t.statSynced,
      TagSyncStatus.onlyLocal => t.badgeOnlyLocal,
      TagSyncStatus.onlyRemote => t.badgeOnlyRemote,
      TagSyncStatus.diverged => t.diverged,
    };
    return Chip(
      label: Text(label,
          style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class CompareRow extends StatelessWidget {
  final TagCompareItem item;
  final AppStrings t;
  final AppLang lang;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onViewCommit;
  const CompareRow({
    super.key,
    required this.item,
    required this.t,
    required this.lang,
    required this.expanded,
    required this.onToggle,
    required this.onViewCommit,
  });

  @override
  Widget build(BuildContext context) {
    // 对标原版 OutlinedCard(onClick = onToggle)：整卡可点展开/收起
    return Card.outlined(
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                StatusBadge(status: item.status, t: t),
              ],
            ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 12,
                children: [
                  Text(
                    item.local != null
                        ? '${t.statLocal} ● ${item.local!.commitSha != null ? _short8(item.local!.commitSha!) : t.noSha}'
                        : '${t.statLocal} ○ ${t.missing}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    item.remote != null
                        ? '${t.statRemote} ● ${item.remote!.commitSha != null ? _short8(item.remote!.commitSha!) : t.noSha}'
                        : '${t.statRemote} ○ ${t.missing}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              finalSubject(context),
              if (expanded) ...[
                Text(t.detailTitle,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TagSideDetail(
                    side: t.statLocal,
                    t: t,
                    tag: item.local,
                    missingHint: t.missingPushHint),
                TagSideDetail(
                    side: t.statRemote,
                    t: t,
                    tag: item.remote,
                    missingHint: t.missingPullHint),
                Text(
                  switch (item.status) {
                    TagSyncStatus.synced => t.explainSynced,
                    TagSyncStatus.onlyLocal =>
                      t.explainOnlyLocal(item.name),
                    TagSyncStatus.onlyRemote =>
                      t.explainOnlyRemote(item.name),
                    TagSyncStatus.diverged => t.explainDiverged,
                  },
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant),
                ),
                if (item.local?.commitSha != null ||
                    item.remote?.commitSha != null)
                  OutlinedButton(
                      onPressed: onViewCommit,
                      child: Text(t.viewCommitBtn)),
              ] else
                Text(t.expandHint,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget finalSubject(BuildContext context) {
    final subject =
        item.local?.commitSubject ?? item.remote?.commitSubject;
    if (subject == null || subject.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(subject,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color:
                Theme.of(context).colorScheme.onSurfaceVariant),
        maxLines: 1,
        overflow: TextOverflow.ellipsis);
  }
}

class TagSideDetail extends StatelessWidget {
  final String side;
  final AppStrings t;
  final GitTag? tag;
  final String missingHint;
  const TagSideDetail({
    super.key,
    required this.side,
    required this.t,
    required this.tag,
    required this.missingHint,
  });

  @override
  Widget build(BuildContext context) {
    final small = Theme.of(context).textTheme.bodySmall;
    final dim = Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText('$side commit: ${tag?.commitSha ?? missingHint}',
            style: small),
        if (tag != null) ...[
          if (tag!.commitSubject?.trim().isNotEmpty ?? false)
            Text(tag!.commitSubject!,
                style: small?.copyWith(fontWeight: FontWeight.w600)),
          _join([tag!.commitAuthor, tag!.commitDate]) != null
            ? Text(_join([tag!.commitAuthor, tag!.commitDate])!,
                style: dim)
            : const SizedBox.shrink(),
          if (tag!.commitBody?.trim().isNotEmpty ?? false)
            Text(tag!.commitBody!, style: dim),
          if (tag!.isAnnotated != null)
            Text(
                '${t.tagTypePrefix}: ${tag!.isAnnotated! ? t.annotatedLong : t.lightweightLong}',
                style: dim),
          if (tag!.tagMessage?.trim().isNotEmpty ?? false)
            Text(
              _tagNotes(),
              style: dim,
            ),
        ],
      ],
    );
  }

  String? _join(List<String?> parts) {
    final v =
        parts.where((e) => e != null && e.trim().isNotEmpty).join(' · ');
    return v.isEmpty ? null : v;
  }

  String _tagNotes() {
    final by = [
      if (tag!.tagger?.trim().isNotEmpty ?? false) tag!.tagger!,
      if (tag!.tagDate?.trim().isNotEmpty ?? false) tag!.tagDate!,
    ].join(' · ');
    if (by.isNotEmpty) {
      return '${t.tagNotesPrefix}($by): ${tag!.tagMessage}';
    }
    return '${t.tagNotesPrefix}: ${tag!.tagMessage}';
  }
}

class CopyableId extends StatefulWidget {
  final String sha;
  final AppStrings t;
  final TextStyle? style;
  final ValueChanged<String>? onCopy;
  const CopyableId(
      {super.key,
      required this.sha,
      required this.t,
      this.style,
      this.onCopy});

  @override
  State<CopyableId> createState() => _CopyableIdState();
}

class _CopyableIdState extends State<CopyableId> {
  bool copied = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: widget.sha));
        widget.onCopy?.call(widget.sha);
        setState(() => copied = true);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => copied = false);
        });
      },
      child: Text(
        copied
            ? widget.t.copied
            : widget.sha.length <= 8
                ? widget.sha
                : widget.sha.substring(0, 8),
        style: (widget.style ??
                Theme.of(context).textTheme.labelSmall)
            ?.copyWith(
                color: copied
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant),
      ),
    );
  }
}

class RecordRow extends StatelessWidget {
  final String label;
  final SubmoduleRecord r;
  final AppStrings t;
  final Color color;
  final ValueChanged<String>? onCopy;
  const RecordRow({
    super.key,
    required this.label,
    required this.r,
    required this.t,
    required this.color,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final brief = [
      if (r.author?.trim().isNotEmpty ?? false) r.author!,
      if (r.date?.trim().isNotEmpty ?? false) r.date!,
      if (r.subject?.trim().isNotEmpty ?? false) r.subject!,
    ].join(' · ');
    return Row(
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color)),
        const SizedBox(width: 4),
        CopyableId(sha: r.sha, t: t, onCopy: onCopy),
        if (brief.isNotEmpty)
          Expanded(
            child: Text('（$brief）',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
      ],
    );
  }
}

String? subBrief(String? author, String? date, String? subject) {
  final v = [
    if (author?.trim().isNotEmpty ?? false) author!,
    if (date?.trim().isNotEmpty ?? false) date!,
    if (subject?.trim().isNotEmpty ?? false) subject!,
  ].join(' · ');
  return v.isEmpty ? null : v;
}

class CommitRow extends StatelessWidget {
  final GitCommit commit;
  final AppStrings t;
  final ValueChanged<String> onTagClick;
  final void Function(String path, String? sha) onSubmoduleClick;
  final ValueChanged<String>? onCopy;
  const CommitRow({
    super.key,
    required this.commit,
    required this.t,
    required this.onTagClick,
    required this.onSubmoduleClick,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greenColor =
        isDark ? const Color(0xFF81C784) : const Color(0xFF1B7A3D);
    final droppedColor =
        isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100);
    final isMerge = commit.parents.length > 1;
    return Card.outlined(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CopyableId(sha: commit.sha, t: t, onCopy: onCopy),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    [
                      commit.subject?.trim().isNotEmpty ?? false
                          ? commit.subject!
                          : t.emptySubject,
                      if (commit.author?.trim().isNotEmpty ?? false)
                        commit.author!,
                      if (commit.date?.trim().isNotEmpty ?? false)
                        commit.date!,
                    ].join(' · '),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (commit.nonTagRefs.isNotEmpty)
              Text(commit.nonTagRefs.join(', '),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(
                          color:
                              Theme.of(context).colorScheme.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            if (commit.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                children: commit.tags
                    .map((tagName) => InkWell(
                          onTap: () => onTagClick(tagName),
                          child: Text('◆ $tagName',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                        ))
                    .toList(),
              ),
            for (final ch in commit.submoduleChanges) ...[
              _greenLine(context, ch, greenColor),
              _traceLines(context, ch, isMerge),
              if (ch.silentlyDropped && ch.droppedSha != null)
                _droppedLine(context, ch, droppedColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _greenLine(
      BuildContext context, SubmoduleChange ch, Color greenColor) {
    final small =
        Theme.of(context).textTheme.labelMedium?.copyWith(color: greenColor);
    final shortName = ch.path.split('/').last.split('\\').last;
    final name = shortName.isEmpty ? ch.path : shortName;
    List<Widget> spans = [];
    if (ch.isAdded) {
      spans = [
        Text('$name ${t.addedWord}', style: small),
        CopyableId(sha: ch.newSha ?? '?', t: t, onCopy: onCopy),
        if (subBrief(ch.newAuthor, ch.newDate, ch.newSubject) != null)
          Expanded(
              child: Text(
                  '(${subBrief(ch.newAuthor, ch.newDate, ch.newSubject)})',
                  style: small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
      ];
    } else if (ch.isRemoved) {
      spans = [
        Text('$name ${t.removedWord}', style: small),
        CopyableId(sha: ch.oldSha ?? '?', t: t, onCopy: onCopy),
        if (subBrief(ch.oldAuthor, ch.oldDate, ch.oldSubject) != null)
          Expanded(
              child: Text(
                  '(${subBrief(ch.oldAuthor, ch.oldDate, ch.oldSubject)})',
                  style: small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
      ];
    } else {
      spans = [
        Text('$name ${t.fromWord}', style: small),
        CopyableId(sha: ch.oldSha ?? '?', t: t, onCopy: onCopy),
        if (subBrief(ch.oldAuthor, ch.oldDate, ch.oldSubject) != null)
          Flexible(
              child: Text(
                  '(${subBrief(ch.oldAuthor, ch.oldDate, ch.oldSubject)})',
                  style: small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        Text(ch.resolvedInMerge ? t.mergeEdited : '→',
            style: small),
        CopyableId(sha: ch.newSha ?? '?', t: t, onCopy: onCopy),
        if (subBrief(ch.newAuthor, ch.newDate, ch.newSubject) != null)
          Expanded(
              child: Text(
                  '(${subBrief(ch.newAuthor, ch.newDate, ch.newSubject)})',
                  style: small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
      ];
    }
    return Row(children: [
      for (var i = 0; i < spans.length; i++) ...[
        if (i > 0) const SizedBox(width: 2),
        spans[i],
      ],
    ]);
  }

  Widget _traceLines(
      BuildContext context, SubmoduleChange ch, bool isMerge) {
    final prev = ch.recordedBy;
    final actual = ch.actualSwitchBy;
    final primary = Theme.of(context).colorScheme.primary;
    if (isMerge) {
      if (actual != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecordRow(
                label: t.newValueFrom,
                r: actual,
                t: t,
                color: primary,
                onCopy: onCopy),
            if (prev != null && prev.sha != actual.sha)
              RecordRow(
                  label: prev.isMerge ? t.oldFromMerge : t.oldFrom,
                  r: prev,
                  t: t,
                  color: primary,
                  onCopy: onCopy),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prev != null)
            RecordRow(
                label: prev.isMerge ? t.oldFromMerge : t.oldFrom,
                r: prev,
                t: t,
                color: primary,
                onCopy: onCopy),
          if (ch.newSha != null && !ch.resolvedInMerge)
            Text(t.newValueUnknown,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
        ],
      );
    }
    if (prev == null) return const SizedBox.shrink();
    return RecordRow(
      label: prev.isMerge ? t.oldFromMerge : t.lastSwitch,
      r: prev,
      t: t,
      color: primary,
      onCopy: onCopy,
    );
  }

  Widget _droppedLine(
      BuildContext context, SubmoduleChange ch, Color droppedColor) {
    final small = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: droppedColor);
    return Row(
      children: [
        Text(t.silentDrop, style: small),
        const SizedBox(width: 2),
        CopyableId(sha: ch.droppedSha!, t: t, onCopy: onCopy),
        if (ch.droppedSha == ch.oldSha &&
            subBrief(ch.oldAuthor, ch.oldDate, ch.oldSubject) !=
                null)
          Flexible(
              child: Text(
                  '（${subBrief(ch.oldAuthor, ch.oldDate, ch.oldSubject)}）',
                  style: small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 2),
        Text(t.keptWord, style: small),
        const SizedBox(width: 2),
        CopyableId(sha: ch.newSha ?? '?', t: t, onCopy: onCopy),
        if (subBrief(ch.newAuthor, ch.newDate, ch.newSubject) !=
            null)
          Expanded(
              child: Text(
                  '（${subBrief(ch.newAuthor, ch.newDate, ch.newSubject)}）',
                  style: small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class SimpleTagRow extends StatelessWidget {
  final GitTag tag;
  final AppStrings t;
  final String sideLabel;
  final bool expanded;
  final VoidCallback onToggle;
  const SimpleTagRow({
    super.key,
    required this.tag,
    required this.t,
    required this.sideLabel,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // 对标原版 OutlinedCard(onClick = onToggle)：整卡可点展开/收起
    return Card.outlined(
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Expanded(
                  child: Text(tag.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                  Text(
                    sideLabel +
                        (tag.isAnnotated == null
                            ? ''
                            : tag.isAnnotated!
                                ? ' · ${t.annotatedShort}'
                                : ' · ${t.lightweightShort}'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant),
                  ),
                ],
              ),
              if (tag.commitSubject?.trim().isNotEmpty ?? false)
                Text(tag.commitSubject!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              Text(
                tag.commitSha != null
                    ? 'commit: ${tag.commitSha!.length > 12 ? '${tag.commitSha!.substring(0, 12)}…' : tag.commitSha}'
                    : t.pureNameNoSha,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant),
              ),
              if (expanded)
                TagSideDetail(
                    side: t.fullSide,
                    t: t,
                    tag: tag,
                    missingHint: '—')
              else
                Text(t.expandHint,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyHint extends StatelessWidget {
  final String text;
  const EmptyHint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text,
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

extension on String {
  bool get isNotBlank => trim().isNotEmpty;
}

String _short8(String sha) =>
    sha.length <= 8 ? sha : sha.substring(0, 8);
