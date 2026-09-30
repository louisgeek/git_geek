import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git_geek/l10n/gen/app_localizations.dart';
import 'package:git_geek/core/widgets/clipboard.dart';
import 'package:git_geek/data/git_runner.dart';
import 'package:git_geek/features/commits/presentation/commits_notifier.dart';
import 'package:git_geek/features/commits/presentation/widgets/commit_control_card.dart';
import 'package:git_geek/features/commits/presentation/widgets/commit_list.dart';
import 'package:git_geek/features/tags/presentation/tags_notifier.dart';
import 'package:git_geek/features/workspace/presentation/widgets/app_nav_bar.dart';
import 'package:git_geek/features/workspace/presentation/widgets/app_title.dart';
import 'package:git_geek/features/workspace/presentation/widgets/repo_card.dart';
import 'package:git_geek/features/workspace/presentation/widgets/unsupported_card.dart';
import 'package:git_geek/features/workspace/presentation/workspace_notifier.dart';
import 'package:go_router/go_router.dart';

/// Commits 页（路由 /commits）：标题 + 仓库卡 + 提交控制 + 提交列表。
class CommitsPage extends ConsumerStatefulWidget {
  const CommitsPage({super.key});

  @override
  ConsumerState<CommitsPage> createState() => _CommitsPageState();
}

class _CommitsPageState extends ConsumerState<CommitsPage> {
  WorkspaceNotifier get vm => ref.read(workspaceProvider.notifier);

  @override
  void initState() {
    super.initState();
    // 首帧后懒加载提交，避免在 initState 同步读写 provider。
    Future.microtask(
      () => ref.read(workspaceProvider.notifier).ensureCommitsLoaded(),
    );
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),
                  AppTitle(
                    lang: ui.lang,
                    t: t,
                    onLangSelected: vm.setLang,
                  ),
                  const SizedBox(height: 12),
                  RepoCard(
                    ui: ui,
                    tags: tags,
                    cs: cs,
                    t: t,
                    vm: vm,
                    onCopy: (v) => copyAndNotify(context, v, t),
                  ),
                  const SizedBox(height: 12),
                  CommitControlCard(
                    cs: cs,
                    selectedScope: ui.selectedScope,
                    t: t,
                    cn: ref.read(commitsProvider.notifier),
                    onSelectBranch: vm.selectBranch,
                    onRefreshCommits: vm.refreshCommits,
                  ),
                  const SizedBox(height: 8),
                  CommitList(
                    cs: cs,
                    t: t,
                    onTagClick: (name) {
                      vm.viewTagFromCommit(name);
                      context.go('/tags');
                    },
                    onSubmoduleClick: vm.viewSubmoduleChange,
                    onCopy: (v) => copyAndNotify(context, v, t),
                  ),
                  const SizedBox(height: 12),
                  if (!supportsNativeGit) UnsupportedCard(t: t),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppNavBar(
        currentIndex: 1,
        t: t,
        onTap: (i) {
          if (i == 0) context.go('/tags');
        },
      ),
    );
  }
}
