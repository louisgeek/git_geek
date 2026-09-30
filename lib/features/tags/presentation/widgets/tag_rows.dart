import 'package:flutter/material.dart';
import 'package:git_geek/l10n/gen/app_localizations.dart';
import 'package:git_geek/models/git_tag.dart';

/// Tag 行组件（原 GitTagPage 同名类，原样迁移）。
/// 另删掉了 `CompareRow.lang`：该字段存了但 build 里从没用过。
/// 同步状态徽标。
class StatusBadge extends StatelessWidget {
  final TagSyncStatus status;
  final AppLocalizations t;

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
      label: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

/// 对比行：展示同名 tag 本地/远端摘要，展开看详情。
class CompareRow extends StatelessWidget {
  final TagCompareItem item;
  final AppLocalizations t;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onViewCommit;

  const CompareRow({
    super.key,
    required this.item,
    required this.t,
    required this.expanded,
    required this.onToggle,
    required this.onViewCommit,
  });

  @override
  Widget build(BuildContext context) {
    // 整卡可点展开/收起
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
                    child: Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                Text(
                  t.detailTitle,
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TagSideDetail(
                  side: t.statLocal,
                  t: t,
                  tag: item.local,
                  missingHint: t.missingPushHint,
                ),
                TagSideDetail(
                  side: t.statRemote,
                  t: t,
                  tag: item.remote,
                  missingHint: t.missingPullHint,
                ),
                Text(
                  switch (item.status) {
                    TagSyncStatus.synced => t.explainSynced,
                    TagSyncStatus.onlyLocal => t.explainOnlyLocal(item.name),
                    TagSyncStatus.onlyRemote => t.explainOnlyRemote(item.name),
                    TagSyncStatus.diverged => t.explainDiverged,
                  },
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (item.local?.commitSha != null ||
                    item.remote?.commitSha != null)
                  OutlinedButton(
                    onPressed: onViewCommit,
                    child: Text(t.viewCommitBtn),
                  ),
              ] else
                Text(
                  t.expandHint,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 首选主题：本地优先，否则用远端。
  Widget finalSubject(BuildContext context) {
    final subject = item.local?.commitSubject ?? item.remote?.commitSubject;
    if (subject == null || subject.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      subject,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// 单侧 tag 详情：提交信息 + 附注类型与备注。
class TagSideDetail extends StatelessWidget {
  final String side;
  final AppLocalizations t;
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
    final dim = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          '$side commit: ${tag?.commitSha ?? missingHint}',
          style: small,
        ),
        if (tag != null) ...[
          if (tag!.commitSubject?.trim().isNotEmpty ?? false)
            Text(
              tag!.commitSubject!,
              style: small?.copyWith(fontWeight: FontWeight.w600),
            ),
          _join([tag!.commitAuthor, tag!.commitDate]) != null
              ? Text(_join([tag!.commitAuthor, tag!.commitDate])!, style: dim)
              : const SizedBox.shrink(),
          if (tag!.commitBody?.trim().isNotEmpty ?? false)
            Text(tag!.commitBody!, style: dim),
          if (tag!.isAnnotated != null)
            Text(
              '${t.tagTypePrefix}: ${tag!.isAnnotated! ? t.annotatedLong : t.lightweightLong}',
              style: dim,
            ),
          if (tag!.tagMessage?.trim().isNotEmpty ?? false)
            Text(_tagNotes(), style: dim),
        ],
      ],
    );
  }

  String? _join(List<String?> parts) {
    final v = parts.where((e) => e != null && e.trim().isNotEmpty).join(' · ');
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

/// 单侧 tag 行：本地/远端列表用，展开看完整详情。
class SimpleTagRow extends StatelessWidget {
  final GitTag tag;
  final AppLocalizations t;
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
    // 整卡可点展开/收起
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
                    child: Text(
                      tag.name,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    sideLabel +
                        (tag.isAnnotated == null
                            ? ''
                            : tag.isAnnotated!
                            ? ' · ${t.annotatedShort}'
                            : ' · ${t.lightweightShort}'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (tag.commitSubject?.trim().isNotEmpty ?? false)
                Text(
                  tag.commitSubject!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                tag.commitSha != null
                    ? 'commit: ${tag.commitSha!.length > 12 ? '${tag.commitSha!.substring(0, 12)}…' : tag.commitSha}'
                    : t.pureNameNoSha,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (expanded)
                TagSideDetail(
                  side: t.fullSide,
                  t: t,
                  tag: tag,
                  missingHint: '—',
                )
              else
                Text(
                  t.expandHint,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 截短 sha：超 8 位取前 8 位。
String _short8(String sha) => sha.length <= 8 ? sha : sha.substring(0, 8);
