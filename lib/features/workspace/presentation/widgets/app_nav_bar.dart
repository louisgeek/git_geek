import 'package:flutter/material.dart';
import 'package:git_geek/l10n/gen/app_localizations.dart';

/// 底部双页导航（/tags、/commits），当前页高亮由调用方传 [currentIndex]。
class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final AppLocalizations t;
  final ValueChanged<int> onTap;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.t,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
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
    );
  }
}
