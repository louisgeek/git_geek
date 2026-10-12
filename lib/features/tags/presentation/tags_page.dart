import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git_geek/l10n/gen/app_localizations.dart';
import 'package:git_geek/core/widgets/clipboard.dart';
import 'package:git_geek/di/git.dart';
import 'package:git_geek/features/commits/presentation/commits_notifier.dart';
import 'package:git_geek/features/tags/presentation/tags_notifier.dart';
import 'package:git_geek/features/tags/presentation/tags_state.dart';
import 'package:git_geek/features/tags/presentation/widgets/tag_lists.dart';
import 'package:git_geek/features/tags/presentation/widgets/tag_search_sort.dart';
import 'package:git_geek/features/tags/presentation/widgets/tag_stats.dart';
import 'package:git_geek/features/workspace/presentation/widgets/app_nav_bar.dart';
import 'package:git_geek/features/workspace/presentation/widgets/app_title.dart';
import 'package:git_geek/features/workspace/presentation/widgets/repo_card.dart';
import 'package:git_geek/features/workspace/presentation/widgets/unsupported_card.dart';
import 'package:git_geek/features/workspace/presentation/workspace_notifier.dart';
import 'package:go_router/go_router.dart';

/// Tags 页（路由 /tags）：标题 + 仓库卡 + 统计 + 搜索排序 + 对比/本地/远端内页签。
class TagsPage extends ConsumerStatefulWidget {
  const TagsPage({super.key});

  @override
  ConsumerState<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends ConsumerState<TagsPage> {
  WorkspaceNotifier get vm => ref.read(workspaceProvider.notifier);
  Set<String> expandedNames = {};

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
    final ui = ref.watch(workspaceProvider);
    final tags = ref.watch(tagsProvider);
    final cs = ref.watch(commitsProvider);
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 头部提为固定区域，与 /commits 页保持一致（切页时标题不跳动）。
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: AppTitle(
                lang: ui.lang,
                t: t,
                onLangSelected: vm.setLang,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  RepoCard(
                    ui: ui,
                    tags: tags,
                    cs: cs,
                    t: t,
                    vm: vm,
                    onCopy: (v) => copyAndNotify(context, v, t.copied),
                  ),
                  const SizedBox(height: 12),
                  TagStats(tags: tags, t: t),
                  const SizedBox(height: 12),
                  TagSearchSort(
                    tags: tags,
                    t: t,
                    tn: ref.read(tagsProvider.notifier),
                  ),
                  const SizedBox(height: 12),
                  _buildInnerTabs(tags, t),
                  const SizedBox(height: 12),
                  TagLists(
                    selectedTab: ui.selectedTagTab,
                    tags: tags,
                    t: t,
                    expandedNames: expandedNames,
                    onToggleExpand: toggleExpand,
                    onViewCommit: (item) {
                      vm.viewCommitForTag(item);
                      context.go('/commits');
                    },
                  ),
                  const SizedBox(height: 12),
                  if (!ref.watch(supportsNativeGitProvider))
                    UnsupportedCard(t: t),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppNavBar(
        currentIndex: 0,
        t: t,
        onTap: (i) {
          if (i == 1) context.go('/commits');
        },
      ),
    );
  }

  Widget _buildInnerTabs(TagsState tags, AppLocalizations t) {
    final ui = ref.watch(workspaceProvider);
    return DefaultTabController(
      length: 3,
      // 页签下标钳制到 0~2，防越界。
      initialIndex: ui.selectedTagTab.clamp(0, 2),
      child: Builder(
        builder: (context) {
          final ctrl = DefaultTabController.of(context);
          if (ctrl.index != ui.selectedTagTab.clamp(0, 2)) {
            // 同步外部 selectedTagTab（避免 setState 循环，用 microtask）
            Future.microtask(() {
              if (ctrl.index != ui.selectedTagTab.clamp(0, 2)) {
                ctrl.animateTo(ui.selectedTagTab.clamp(0, 2));
              }
            });
          }
          return TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            onTap: vm.setTagTab,
            tabs: [
              Tab(text: '${t.tabCompare}(${tags.visibleCompare.length})'),
              Tab(text: '${t.statLocal}(${tags.visibleLocal.length})'),
              Tab(text: '${t.statRemote}(${tags.visibleRemote.length})'),
            ],
          );
        },
      ),
    );
  }
}
