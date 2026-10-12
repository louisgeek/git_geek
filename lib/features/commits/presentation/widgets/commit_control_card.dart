import 'package:flutter/material.dart';
import 'package:git_geek/l10n/gen/app_localizations.dart';
import 'package:git_geek/core/widgets/clearable_text_field.dart';
import 'package:git_geek/features/commits/presentation/commits_notifier.dart';
import 'package:git_geek/features/commits/presentation/commits_state.dart';

/// 提交控制卡（原 GitTagPage._buildCommitControlCard，原样迁移仅换调用方式）：
/// 范围文本由调用方透传 [selectedScope]（与 CommitsState.scope 同步），
/// 分支切换/刷新走 [onSelectBranch]/[onRefreshCommits] 回调，避免 commits 依赖 workspace。
class CommitControlCard extends StatelessWidget {
  final CommitsState cs;
  final String selectedScope;
  final AppLocalizations t;
  final CommitsNotifier cn;
  final ValueChanged<String> onSelectBranch;
  final VoidCallback onRefreshCommits;

  const CommitControlCard({
    super.key,
    required this.cs,
    required this.selectedScope,
    required this.t,
    required this.cn,
    required this.onSelectBranch,
    required this.onRefreshCommits,
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
              '${t.currentScopePrefix}: ${selectedScope.isEmpty ? t.mainRepo : '${t.submoduleWord} $selectedScope'}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ClearableTextField(
              value: cs.commitQuery,
              onChanged: cn.setCommitQuery,
              label: t.searchCommitLabel,
            ),
            if (cs.branches.isNotEmpty || cs.isLoadingBranches) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  FilterChip(
                    selected: cs.branch.isEmpty,
                    onSelected: (_) => onSelectBranch(''),
                    label: Text(
                      t.currentBranchChip,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  FilterChip(
                    selected: cs.branch == '--all',
                    onSelected: (_) => onSelectBranch('--all'),
                    label: Text(
                      '--all',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  for (final b in cs.branches)
                    FilterChip(
                      selected:
                          cs.branch == b.name ||
                          (cs.branch.isEmpty && b.isCurrent),
                      onSelected: (_) => onSelectBranch(b.name),
                      label: Text(
                        '${b.isCurrent ? '* ' : ''}${b.name}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                ],
              ),
            ],
            if (cs.branchError != null)
              Text(
                '${t.errBranchPrefix}: ${cs.branchError}',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClearableTextField(
                    value: cs.branch,
                    onChanged: cn.setBranch,
                    label: t.branchLabel,
                    placeholder: t.branchPlaceholder,
                  ),
                ),
                const SizedBox(width: 8),
                // 条数框要放得下 label 与清空按钮，且最多可填 4 位（上限 5000），
                // 80px 会把 label 压到截断，这里给足宽度。
                SizedBox(
                  width: _limitFieldWidth,
                  child: ClearableTextField(
                    value: cs.commitLimit,
                    onChanged: cn.setCommitLimit,
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
                  onPressed: cs.isLoadingCommits ? null : onRefreshCommits,
                  child: Text(t.btnRefreshCommits),
                ),
                FilterChip(
                  selected: cs.newestFirst,
                  onSelected: (_) => cn.toggleOrder(),
                  label: Text(cs.newestFirst ? t.newestFirst : t.oldestFirst),
                ),
              ],
            ),
            if (cs.isLoadingCommits) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.loadingCommitsLong,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            if (cs.commitError != null)
              Text(
                '${t.errCommitPrefix}: ${cs.commitError}',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }

  /// 条数输入框宽度：容得下 label 文案 + 清空按钮 + 4 位数字。
  static const double _limitFieldWidth = 112;
}
