import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_geek/app/app.dart';
import 'package:git_geek/core/storage/app_prefs.dart';
import 'package:git_geek/features/commits/presentation/commits_notifier.dart';
import 'package:git_geek/shared/widgets/clearable_text_field.dart';
import 'package:git_geek/features/workspace/presentation/workspace_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 用 workspace.loadSample() 灌固定数据，断言两路由的渲染与过滤。
// 只用数据原文（tag 名/sha/提交信息）与图标断言，不依赖界面语言。
Future<ProviderContainer> pumpApp(WidgetTester tester) async {
  // 页面是 ListView，默认 800x600 视口只会 build 可见子项；
  // 放大到足够高，保证所有行都被构建，便于断言。
  tester.view.physicalSize = const Size(1400, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [appPrefsProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
  // 等路由重定向（/ → /tags）落定。
  await tester.pumpAndSettle();
  container.read(workspaceProvider.notifier).loadSample();
  await tester.pump();
  return container;
}

Future<void> gotoTagTab(WidgetTester tester, int index) async {
  final tab = find.byType(Tab).at(index);
  await tester.ensureVisible(tab);
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

Future<void> gotoCommits(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.history));
  await tester.pumpAndSettle();
}

Future<void> gotoTags(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.compare_arrows));
  await tester.pumpAndSettle();
}

void main() {
  group('tags route with sample data', () {
    testWidgets('compare tab lists all sample tags', (tester) async {
      await pumpApp(tester);
      for (final name in [
        'v1.0.0',
        'v1.1.0',
        'v1.2.0',
        'v1.3.0',
        'v2.0.0-rc.1',
        'v2.0.0',
      ]) {
        expect(find.text(name), findsWidgets,
            reason: 'compare tab should show $name');
      }
    });

    testWidgets('local tab hides remote-only tags', (tester) async {
      await pumpApp(tester);
      await gotoTagTab(tester, 1);
      expect(find.text('v2.0.0'), findsWidgets);
      expect(find.text('v1.3.0'), findsNothing);
    });

    testWidgets('remote tab hides local-only tags', (tester) async {
      await pumpApp(tester);
      await gotoTagTab(tester, 2);
      expect(find.text('v1.3.0'), findsWidgets);
      expect(find.text('v2.0.0'), findsNothing);
    });
  });

  group('commits route with sample data', () {
    testWidgets('commits page renders and search filters by real wiring',
        (tester) async {
      final container = await pumpApp(tester);
      await gotoCommits(tester);
      // 提交行把 subject/author/date 用 ' · ' 拼在一行，故用 contains。
      expect(find.textContaining('fix: 修复启动闪退'), findsWidgets);
      expect(find.textContaining('feat: 新增深色模式'), findsWidgets);

      // 走真实输入框接线：按 onChanged 回调定位提交搜索框
      // （页面有多个 ClearableTextField，用 label 依赖语言不可靠）。
      final cn = container.read(commitsProvider.notifier);
      final commitSearch = find.byWidgetPredicate((w) =>
          w is ClearableTextField && w.onChanged == cn.setCommitQuery);
      expect(commitSearch, findsOneWidget);
      await tester.enterText(commitSearch, '深色模式');
      await tester.pump();
      expect(find.textContaining('feat: 新增深色模式'), findsWidgets);
      expect(find.textContaining('fix: 修复启动闪退'), findsNothing);

      // 恢复：notifier 状态与输入框双向一致。
      cn.setCommitQuery('');
      await tester.pump();
      expect(find.textContaining('fix: 修复启动闪退'), findsWidgets);
    });

    testWidgets('nav back to tags keeps sample tags', (tester) async {
      await pumpApp(tester);
      await gotoCommits(tester);
      expect(find.textContaining('fix: 修复启动闪退'), findsWidgets);
      await gotoTags(tester);
      expect(find.text('v1.0.0'), findsWidgets);
    });
  });
}
