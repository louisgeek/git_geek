import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git_geek/shared/l10n/l10n_extensions.dart';
import 'package:git_geek/core/navigation/routes.dart';
import 'package:git_geek/shared/widgets/clipboard.dart';
import 'package:git_geek/core/git/git_providers.dart';
import 'package:git_geek/features/commits/presentation/commits_notifier.dart';
import 'package:git_geek/features/commits/presentation/widgets/commit_control_card.dart';
import 'package:git_geek/features/commits/presentation/widgets/commit_list.dart';
import 'package:git_geek/features/commits/presentation/widgets/submodule_log_panel.dart';
import 'package:git_geek/features/workspace/presentation/widgets/app_title.dart';
import 'package:git_geek/features/workspace/presentation/widgets/repo_card.dart';
import 'package:git_geek/features/workspace/presentation/widgets/unsupported_card.dart';
import 'package:git_geek/features/workspace/presentation/workspace_notifier.dart';
import 'package:go_router/go_router.dart';

/// Commits 页（路由 /commits）：标题 + 仓库卡 + 提交控制 + 提交列表。
/// 底部导航由 MainShellPage 统一提供，这里只管内容。
class CommitsPage extends ConsumerStatefulWidget {
  const CommitsPage({super.key});

  @override
  ConsumerState<CommitsPage> createState() => _CommitsPageState();
}

class _CommitsPageState extends ConsumerState<CommitsPage> {
  WorkspaceNotifier get vm => ref.read(workspaceProvider.notifier);

  /// 右侧参照面板宽度（可拖动调整）。
  double _panelWidth = _defaultPanelWidth;

  /// 拖动分割条时的累计横向位移。
  double _dragDelta = 0;

  @override
  void initState() {
    super.initState();
    // 首帧后懒加载提交，避免在 initState 同步读写 provider。
    Future.microtask(
      () => ref.read(workspaceProvider.notifier).ensureCommitsLoaded(),
    );
  }

  /// 拖动中：累加位移但不落定，松手才真正改宽度（避免每像素 setState）。
  void _onPanelDragUpdate(DragUpdateDetails d) {
    setState(() => _dragDelta += d.delta.dx);
  }

  /// 松手：把累计位移一次性折算进宽度，并夹在合理区间内。
  void _onPanelDragEnd(DragEndDetails d) {
    setState(() {
      _panelWidth =
          (_panelWidth - _dragDelta).clamp(_minPanelWidth, _maxPanelWidth);
      _dragDelta = 0;
    });
  }

  /// 拖动被系统打断（手势被别的控件抢走等）：同样要清掉累计位移，
  /// 否则下一次拖动会接着上次的残量跳一段。
  void _onPanelDragCancel() {
    setState(() => _dragDelta = 0);
  }

  /// 双击分割条：回到默认宽度。
  void _resetPanelWidth() {
    setState(() {
      _panelWidth = _defaultPanelWidth;
      _dragDelta = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ui = ref.watch(workspaceProvider);
    final cs = ref.watch(commitsProvider);
    final t = context.l10n;
    final screenWidth = MediaQuery.of(context).size.width;
    // 上限取「屏宽 45%」与 520 的较小值：窄窗口下不会把主库列表挤没。
    final effectiveMax = math.min(screenWidth * _maxPanelRatio, _maxPanelWidth);
    // clamp 要求 lower <= upper。屏幕窄到连下限都容不下时（< ~356px）
    // 说明主库列表更该优先，直接不显示参照面板而非让 clamp 抛参数异常。
    final showPanel = cs.submodules.isNotEmpty && effectiveMax >= _minPanelWidth;
    // 拖动中用「已落定宽度 - 累计位移」实时预览，松手后同样走这套夹取。
    final panelWidth =
        (_panelWidth - _dragDelta).clamp(_minPanelWidth, effectiveMax);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 头部提为左右共用的整宽区域：右侧参照面板的顶部由此自然落在
            // 「语言/关于」那行之下，不会高过头部。
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: AppTitle(
                lang: ui.lang,
                t: t,
                onLangSelected: vm.setLang,
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧：原有纵向内容完全保留，不改任何行为。
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
                      children: [
                        const RepoCard(),
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
                            context.go(AppRoutes.tags);
                          },
                          onSubmoduleClick: vm.viewSubmoduleChange,
                          onCopy: (v) => copyAndNotify(context, v, t.copied),
                        ),
                        const SizedBox(height: 12),
                        if (!ref.watch(supportsNativeGitProvider))
                          UnsupportedCard(t: t),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  // 分割条：仅在有子库（面板可见）时出现，可拖动/双击复位。
                  if (showPanel)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: _onPanelDragUpdate,
                      onHorizontalDragEnd: _onPanelDragEnd,
                      onHorizontalDragCancel: _onPanelDragCancel,
                      onDoubleTap: _resetPanelWidth,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeLeftRight,
                        child: SizedBox(
                          width: _dividerWidth,
                          child: Center(
                            child: Container(
                              width: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // 右侧：子库最近记录参照面板（纯展示，无跳转联动）。
                  if (showPanel)
                    SizedBox(
                      width: panelWidth,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(8, 12, 16, 16),
                        children: [
                          SubmoduleLogPanel(cs: cs, t: t),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 右侧参照面板默认宽度：够放短 sha + 一行主题。
  static const double _defaultPanelWidth = 232;

  /// 拖动下限：再窄就放不下「短 sha + 主题」了。
  static const double _minPanelWidth = 160;

  /// 参照面板宽度上限（不含屏宽约束）。
  static const double _maxPanelWidth = 520;

  /// 面板最多占屏宽的比例，剩下的留给主库列表。
  static const double _maxPanelRatio = 0.45;

  /// 分割条自身宽度（拖动热区）。
  static const double _dividerWidth = 8;
}
