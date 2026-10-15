import 'package:flutter/material.dart';
import 'package:git_geek/shared/l10n/gen/app_localizations.dart';
import 'package:git_geek/features/tags/presentation/tags_state.dart';

/// Tag 同步统计条（原 GitTagPage._buildStats，原样迁移仅换调用方式）。
class TagStats extends StatelessWidget {
  final TagsState tags;
  final AppLocalizations t;

  const TagStats({super.key, required this.tags, required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final e in [
              (t.statLocal, tags.stats.localCount),
              (t.statRemote, tags.stats.remoteCount),
              (t.statSynced, tags.stats.syncedCount),
              (t.statOnlyLocal, tags.stats.onlyLocalCount),
              (t.statOnlyRemote, tags.stats.onlyRemoteCount),
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: StatCard(label: e.$1, count: e.$2),
                ),
              ),
          ],
        ),
        if (tags.stats.divergedCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              t.divergedWarn(tags.stats.divergedCount),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

/// 单项统计卡：数字 + 标签。
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
            Text(
              '$count',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              label,
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
