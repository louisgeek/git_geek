import 'package:flutter/material.dart';
import 'package:git_geek/app/shell/main_shell_page.dart';
import 'package:git_geek/core/navigation/routes.dart';
import 'package:git_geek/features/commits/presentation/commits_page.dart';
import 'package:git_geek/features/tags/presentation/tags_page.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// 路由装配：StatefulShellRoute 双分支（/tags 对比页与 /commits 日志页互保活），
/// `/` 重定向到 `/tags`。未涉及登录态 redirect、deeplink，先不建。
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.tags,
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.tags,
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShellPage(
          navigationShell: shell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.tags,
                name: 'tags',
                builder: (context, state) => const TagsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.commits,
                name: 'commits',
                builder: (context, state) => const CommitsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}
