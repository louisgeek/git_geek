import 'package:flutter/material.dart';
import 'package:git_geek/shared/l10n/gen/app_localizations.dart';
import 'package:git_geek/shared/widgets/empty_hint.dart';
import 'package:git_geek/features/tags/presentation/tags_state.dart';
import 'package:git_geek/features/tags/presentation/widgets/tag_rows.dart';
import 'package:git_geek/features/tags/domain/git_tag.dart';

/// Tag 三个列表（原 GitTagPage._buildList 的 case 0/1/2，原样迁移仅换调用方式）。
/// 展开态由调用方持有 [expandedNames] + [onToggleExpand]（key 规则不变）；
/// 对比项的“查看提交”走 [onViewCommit] 回调。
class TagLists extends StatelessWidget {
  final int selectedTab;
  final TagsState tags;
  final AppLocalizations t;
  final Set<String> expandedNames;
  final ValueChanged<String> onToggleExpand;
  final ValueChanged<TagCompareItem> onViewCommit;

  const TagLists({
    super.key,
    required this.selectedTab,
    required this.tags,
    required this.t,
    required this.expandedNames,
    required this.onToggleExpand,
    required this.onViewCommit,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedTab) {
      case 0:
        if (tags.visibleCompare.isEmpty) {
          return EmptyHint(text: t.emptyCompare);
        }
        return Column(
          children: tags.visibleCompare
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CompareRow(
                    item: item,
                    t: t,
                    expanded: expandedNames.contains('c-${item.name}'),
                    onToggle: () => onToggleExpand('c-${item.name}'),
                    onViewCommit: () => onViewCommit(item),
                  ),
                ),
              )
              .toList(),
        );
      case 1:
        if (tags.visibleLocal.isEmpty) {
          return EmptyHint(text: t.emptyLocalTab);
        }
        return Column(
          children: tags.visibleLocal
              .map(
                (tag) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SimpleTagRow(
                    tag: tag,
                    t: t,
                    sideLabel: t.statLocal,
                    expanded: expandedNames.contains('l-${tag.name}'),
                    onToggle: () => onToggleExpand('l-${tag.name}'),
                  ),
                ),
              )
              .toList(),
        );
      case 2:
        if (tags.visibleRemote.isEmpty) {
          return EmptyHint(text: t.emptyRemoteTab);
        }
        return Column(
          children: tags.visibleRemote
              .map(
                (tag) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SimpleTagRow(
                    tag: tag,
                    t: t,
                    sideLabel: t.statRemote,
                    expanded: expandedNames.contains('r-${tag.name}'),
                    onToggle: () => onToggleExpand('r-${tag.name}'),
                  ),
                ),
              )
              .toList(),
        );
      default:
        return EmptyHint(text: t.emptyCompare);
    }
  }
}
