import 'package:flutter/material.dart';
import 'package:git_geek/shared/l10n/gen/app_localizations.dart';
import 'package:git_geek/shared/widgets/clearable_text_field.dart';
import 'package:git_geek/features/tags/presentation/tags_notifier.dart';
import 'package:git_geek/features/tags/presentation/tags_state.dart';
import 'package:git_geek/features/tags/domain/git_tag.dart';

/// Tag 搜索 + 排序 + 过滤条（原 GitTagPage._buildSearchSort，原样迁移仅换调用方式）。
/// 查询/排序/过滤动作走同 feature 的 [tn]。
class TagSearchSort extends StatelessWidget {
  final TagsState tags;
  final AppLocalizations t;
  final TagsNotifier tn;

  const TagSearchSort({
    super.key,
    required this.tags,
    required this.t,
    required this.tn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ClearableTextField(
                value: tags.query,
                onChanged: tn.setQuery,
                label: t.searchTagLabel,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<TagSortMode>(
                initialValue: tags.sortMode,
                decoration: InputDecoration(
                  labelText: t.sortLabel,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                items: TagSortMode.values
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text(
                          m.label(t),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (m) {
                  if (m != null) {
                    tn.setSort(m);
                  }
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
              TagFilter.all => tags.allCompare.length,
              TagFilter.synced => tags.stats.syncedCount,
              TagFilter.onlyLocal => tags.stats.onlyLocalCount,
              TagFilter.onlyRemote => tags.stats.onlyRemoteCount,
              TagFilter.diverged => tags.stats.divergedCount,
            };
            return FilterChip(
              selected: tags.filter == f,
              onSelected: (_) => tn.setFilter(f),
              label: Text('${f.label(t)}($count)'),
            );
          }).toList(),
        ),
      ],
    );
  }
}
