import 'package:flutter/material.dart';
import 'package:git_geek/features/commits/presentation/commits_page.dart';
import 'package:git_geek/features/tags/presentation/tags_page.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

/// 路由装配：tags 对比页与 commits 日志页互相独立，`/` 重定向到 `/tags`。
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/tags',
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/tags',
      ),
      GoRoute(
        path: '/tags',
        name: 'tags',
        builder: (context, state) => const TagsPage(),
      ),
      GoRoute(
        path: '/commits',
        name: 'commits',
        builder: (context, state) => const CommitsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}
