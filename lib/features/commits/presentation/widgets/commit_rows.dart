import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:git_geek/shared/l10n/gen/app_localizations.dart';
import 'package:git_geek/features/commits/domain/git_commit.dart';

/// 提交行组件（原 GitTagPage 同名类，原样迁移）。
/// 可点击复制的短 sha。
class CopyableId extends StatefulWidget {
  final String sha;
  final AppLocalizations t;
  final TextStyle? style;
  final ValueChanged<String>? onCopy;

  const CopyableId({
    super.key,
    required this.sha,
    required this.t,
    this.style,
    this.onCopy,
  });

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
        style: (widget.style ?? Theme.of(context).textTheme.labelSmall)
            ?.copyWith(
              color: copied
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

/// 溯源行：展示子模块旧/新值的来源提交。
class RecordRow extends StatelessWidget {
  final String label;
  final SubmoduleRecord r;
  final AppLocalizations t;
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
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
        const SizedBox(width: 4),
        CopyableId(sha: r.sha, t: t, onCopy: onCopy),
        if (brief.isNotEmpty)
          Expanded(
            child: Text(
              '（$brief）',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

/// 拼作者/日期/主题为一行摘要：空返回 null。
String? subBrief(String? author, String? date, String? subject) {
  final v = [
    if (author?.trim().isNotEmpty ?? false) author!,
    if (date?.trim().isNotEmpty ?? false) date!,
    if (subject?.trim().isNotEmpty ?? false) subject!,
  ].join(' · ');
  return v.isEmpty ? null : v;
}

/// 提交行：主题 + 引用 + tag + 子模块变更与溯源。
class CommitRow extends StatelessWidget {
  final GitCommit commit;
  final AppLocalizations t;
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
    final greenColor = isDark
        ? const Color(0xFF81C784)
        : const Color(0xFF1B7A3D);
    final droppedColor = isDark
        ? const Color(0xFFFFB74D)
        : const Color(0xFFE65100);
    final isMerge = commit.parents.length > 1;
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                      if (commit.date?.trim().isNotEmpty ?? false) commit.date!,
                    ].join(' · '),
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (commit.nonTagRefs.isNotEmpty)
              Text(
                commit.nonTagRefs.join(', '),
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (commit.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                children: commit.tags
                    .map(
                      (tagName) => InkWell(
                        onTap: () => onTagClick(tagName),
                        child: Text(
                          '◆ $tagName',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    )
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
    BuildContext context,
    SubmoduleChange ch,
    Color greenColor,
  ) {
    final small = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: greenColor);
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
        Text(ch.resolvedInMerge ? t.mergeEdited : '→', style: small),
        CopyableId(sha: ch.newSha ?? '?', t: t, onCopy: onCopy),
        if (subBrief(ch.newAuthor, ch.newDate, ch.newSubject) != null)
          Expanded(
            child: Text(
              '(${subBrief(ch.newAuthor, ch.newDate, ch.newSubject)})',
              style: small,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ];
    }
    return Row(
      children: [
        for (var i = 0; i < spans.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          spans[i],
        ],
      ],
    );
  }

  Widget _traceLines(BuildContext context, SubmoduleChange ch, bool isMerge) {
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
              onCopy: onCopy,
            ),
            if (prev != null && prev.sha != actual.sha)
              RecordRow(
                label: prev.isMerge ? t.oldFromMerge : t.oldFrom,
                r: prev,
                t: t,
                color: primary,
                onCopy: onCopy,
              ),
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
              onCopy: onCopy,
            ),
          if (ch.newSha != null && !ch.resolvedInMerge)
            Text(
              t.newValueUnknown,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
    BuildContext context,
    SubmoduleChange ch,
    Color droppedColor,
  ) {
    final small = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: droppedColor);
    return Row(
      children: [
        Text(t.silentDrop, style: small),
        const SizedBox(width: 2),
        CopyableId(sha: ch.droppedSha!, t: t, onCopy: onCopy),
        if (ch.droppedSha == ch.oldSha &&
            subBrief(ch.oldAuthor, ch.oldDate, ch.oldSubject) != null)
          Flexible(
            child: Text(
              '（${subBrief(ch.oldAuthor, ch.oldDate, ch.oldSubject)}）',
              style: small,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(width: 2),
        Text(t.keptWord, style: small),
        const SizedBox(width: 2),
        CopyableId(sha: ch.newSha ?? '?', t: t, onCopy: onCopy),
        if (subBrief(ch.newAuthor, ch.newDate, ch.newSubject) != null)
          Expanded(
            child: Text(
              '（${subBrief(ch.newAuthor, ch.newDate, ch.newSubject)}）',
              style: small,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
