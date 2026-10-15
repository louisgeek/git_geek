import 'package:flutter/material.dart';
import 'package:git_geek/features/commits/presentation/commits_state.dart';
import 'package:git_geek/shared/l10n/gen/app_localizations.dart';
import 'package:git_geek/features/commits/domain/git_commit.dart';

/// 子库最近记录参照面板（纯展示）。
///
/// 目的：在 log 页主库提交列表之外，右侧固定展示各子模块自己的最近几条提交，
/// 方便肉眼横向对照主库指针变化与子库实际历史顺序。
/// 刻意不含跳转/点击联动，仅作参照。
class SubmoduleLogPanel extends StatelessWidget {
  final CommitsState cs;
  final AppLocalizations t;

  /// 每个子库最多展示几条。
  final int perSubLimit;

  /// 未初始化/未拉取时是否隐藏整个面板。
  final bool collapseWhenEmpty;

  const SubmoduleLogPanel({
    super.key,
    required this.cs,
    required this.t,
    this.perSubLimit = 10,
    this.collapseWhenEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    if (cs.submodules.isEmpty) return const SizedBox.shrink();
    final logs = cs.submoduleLogs;
    final hasAny = logs.values.any((e) => e.isNotEmpty);
    if (collapseWhenEmpty && !hasAny && !cs.isLoadingSubmoduleLogs) {
      return const SizedBox.shrink();
    }
    final sub = Theme.of(context).textTheme.labelSmall;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(t.subLogPanelTitle, style: sub),
                const SizedBox(width: 8),
                if (cs.isLoadingSubmoduleLogs)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.6),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (!hasAny && !cs.isLoadingSubmoduleLogs)
              Text(t.subLogPanelEmpty, style: sub?.copyWith(color: muted)),
            for (final s in cs.submodules) ...[
              _SubHeader(
                sub: sub,
                muted: muted,
                t: t,
                name: s.displayName,
                sha: s.shortSha,
              ),
              // 未初始化的子库没有工作目录，明确标注而非留空块。
              if (s.status == SubmoduleStatus.uninitialized)
                Padding(
                  padding: const EdgeInsets.only(left: 9, bottom: 2),
                  child: Text(
                    t.subUninitialized,
                    style: sub?.copyWith(color: muted),
                  ),
                )
              else
                for (final c
                    in (logs[s.path] ?? const <GitCommit>[]).take(perSubLimit))
                  _SubRow(sub: sub, muted: muted, t: t, commit: c),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  final TextStyle? sub;
  final Color muted;
  final AppLocalizations t;
  final String name;
  final String? sha;

  const _SubHeader({
    required this.sub,
    required this.muted,
    required this.t,
    required this.name,
    required this.sha,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            margin: const EdgeInsets.only(right: 6),
            color: Theme.of(context).colorScheme.primary,
          ),
          Expanded(
            child: Text(
              name,
              style: sub?.copyWith(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (sha != null)
            Text(sha!, style: sub?.copyWith(color: muted)),
        ],
      ),
    );
  }
}

class _SubRow extends StatelessWidget {
  final TextStyle? sub;
  final Color muted;
  final AppLocalizations t;
  final GitCommit commit;

  const _SubRow({
    required this.sub,
    required this.muted,
    required this.t,
    required this.commit,
  });

  @override
  Widget build(BuildContext context) {
    final shortSha = commit.sha.length <= 8
        ? commit.sha
        : commit.sha.substring(0, 8);
    final subject = commit.subject?.trim().isNotEmpty ?? false
        ? commit.subject!.trim()
        : t.emptySubject;
    return Padding(
      padding: const EdgeInsets.only(left: 9, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(shortSha, style: sub?.copyWith(color: muted)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    if (commit.author?.trim().isNotEmpty ?? false)
                      commit.author!.trim(),
                    if (commit.date?.trim().isNotEmpty ?? false)
                      commit.date!.trim(),
                  ].join(' · '),
                  style: sub?.copyWith(color: muted, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
