import 'package:flutter/material.dart';
import 'package:git_geek/l10n/gen/app_localizations.dart';
import 'package:git_geek/core/widgets/clearable_text_field.dart';
import 'package:git_geek/data/git_url.dart';
import 'package:git_geek/features/commits/presentation/commits_state.dart';
import 'package:git_geek/features/tags/presentation/tags_state.dart';
import 'package:git_geek/features/workspace/presentation/workspace_notifier.dart';
import 'package:git_geek/features/workspace/presentation/workspace_state.dart';
import 'package:git_geek/models/git_commit.dart';

/// 仓库配置卡（原 GitTagPage._buildRepoCard，原样迁移仅换调用方式）：
/// 读 workspace/tags/commits 三份 state，动作走 [vm]，复制走 [onCopy]。
class RepoCard extends StatelessWidget {
  final WorkspaceState ui;
  final TagsState tags;
  final CommitsState cs;
  final AppLocalizations t;
  final WorkspaceNotifier vm;
  final ValueChanged<String> onCopy;

  const RepoCard({
    super.key,
    required this.ui,
    required this.tags,
    required this.cs,
    required this.t,
    required this.vm,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.repoCardTitle,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ClearableTextField(
              value: ui.repoPath,
              onChanged: vm.setRepoPath,
              label: t.repoPathLabel,
              placeholder: t.repoPathPlaceholder,
            ),
            if (GitUrlDetector.isRemoteUrl(ui.repoPath.trim())) ...[
              const SizedBox(height: 4),
              Text(
                t.remoteUrlHint,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              if (ui.cacheDirHint.isNotBlank) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${t.cachePrefix}: ${ui.cacheDirHint}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onCopy(ui.cacheDirHint),
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
            if (cs.remoteUrl.isNotBlank) ...[
              const SizedBox(height: 4),
              Text(
                '${ui.remote.isEmpty ? 'origin' : ui.remote}:  ${cs.remoteUrl}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (cs.submodules.isNotEmpty || cs.isLoadingSubmodules) ...[
              const SizedBox(height: 8),
              Text(
                '${t.scopePrefix}: ${ui.selectedScope.isEmpty ? t.mainRepo : ui.selectedScope}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: [
                  FilterChip(
                    selected: ui.selectedScope.isEmpty,
                    onSelected: (_) => vm.selectScope(''),
                    label: Text(
                      t.mainRepo,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  for (final sub in cs.submodules)
                    FilterChip(
                      selected: ui.selectedScope == sub.path,
                      onSelected: (_) => vm.selectScope(sub.path),
                      label: Text(
                        _subChipLabel(cs, sub, t),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                ],
              ),
            ],
            if (cs.submoduleError != null)
              Text(
                '${t.errSubmodulePrefix}: ${cs.submoduleError}',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: tags.isLoadingLocal
                      ? null
                      : () => vm.refreshLocal(),
                  child: Text(t.btnRefreshLocal),
                ),
                FilledButton(
                  onPressed: tags.isLoadingRemote
                      ? null
                      : () => vm.refreshRemote(),
                  child: Text(t.btnRefreshRemote),
                ),
                OutlinedButton(
                  onPressed: tags.isLoading || cs.isLoading
                      ? null
                      : () => vm.refreshAll(),
                  child: Text(t.btnRefreshAll),
                ),
                OutlinedButton(
                  onPressed: () => vm.loadSample(),
                  child: Text(t.btnSample),
                ),
                TextButton(
                  onPressed: () => vm.clearAll(),
                  child: Text(t.btnClear),
                ),
              ],
            ),
            if (cs.isCloning) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cs.cloningInfo.isEmpty
                          ? t.cloningFallback
                          : cs.cloningInfo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (tags.isLoading || cs.isLoading || cs.isCloning) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${tags.isLoadingLocal ? t.loadingLocal : ''}${tags.isLoadingRemote ? t.loadingRemote : ''}${cs.isLoadingCommits ? t.loadingCommits : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            if (tags.localError != null)
              Text(
                '${t.errLocalPrefix}: ${tags.localError}',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            if (tags.remoteError != null)
              Text(
                '${t.errRemotePrefix}: ${tags.remoteError}',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            if (tags.lastRefreshInfo.isNotBlank)
              Text(
                tags.lastRefreshInfo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else if (cs.lastRefreshInfo.isNotBlank)
              Text(
                cs.lastRefreshInfo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _subChipLabel(CommitsState cs, GitSubmodule sub, AppLocalizations t) {
  final buf = StringBuffer(sub.displayName);
  if (sub.shortSha != null) buf.write('  ${sub.shortSha}');
  if (sub.status != SubmoduleStatus.ok) {
    buf.write(' (${sub.status.label(t)})');
  }
  final branch = (cs.submoduleBranches[sub.path]?.trim().isNotEmpty ?? false)
      ? cs.submoduleBranches[sub.path]
      : sub.branch?.trim().isNotEmpty == true
      ? sub.branch
      : null;
  if (branch != null && branch.isNotEmpty) buf.write('  $branch');
  return buf.toString();
}

extension on String {
  bool get isNotBlank => trim().isNotEmpty;
}
