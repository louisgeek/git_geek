import 'package:flutter/material.dart';
import 'package:git_geek/app/shell/main_tab.dart';
import 'package:git_geek/shared/l10n/l10n_extensions.dart';
import 'package:go_router/go_router.dart';

/// 应用外壳：底部导航栏 + 内容区容器（StatefulShellRoute 的分支容器）。
/// 各分支页（Tags/Commits）只管内容，不再各自放 AppNavBar。
class MainShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellPage({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.compare_arrows),
            label: t.tabCompare,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: t.tabCommits,
          ),
        ],
      ),
    );
  }
}

/// MainTab 与 shell 下标互转（顺序与路由分支顺序一致）。
extension MainTabShellX on MainTab {
  static MainTab fromIndex(int index) => MainTab.values[index];
}
