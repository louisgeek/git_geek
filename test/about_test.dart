import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_geek/app/app.dart';
import 'package:git_geek/core/storage/app_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('about opens', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appPrefsProvider.overrideWithValue(prefs)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    // 测试 locale 非 zh 会回退简体（fromLocale），按钮文案为“关于”。
    await tester.tap(find.text('关于'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('关于 GitGeek'), findsOneWidget);
    // 关闭弹窗后消失。
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
