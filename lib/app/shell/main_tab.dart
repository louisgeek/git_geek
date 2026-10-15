import 'package:flutter/material.dart';
import 'package:git_geek/core/navigation/routes.dart';

/// 底部 Tab 枚举：图标、标题 key 解析、路径三件套。
/// 标题文案需 BuildContext 取 l10n，见 MainTabX.label。
enum MainTab {
  tags(AppRoutes.tags, Icons.compare_arrows),
  commits(AppRoutes.commits, Icons.history);

  final String path;
  final IconData icon;

  const MainTab(this.path, this.icon);
}
