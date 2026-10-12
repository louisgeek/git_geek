import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_geek/main.dart';
import 'package:git_geek/core/storage/app_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('GitGeek home renders', (WidgetTester tester) async {
    // 与 main() 一致：预加载 prefs 后 override，避免 appPrefsProvider 抛错。
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appPrefsProvider.overrideWithValue(prefs)],
        child: const MyApp(),
      ),
    );
    // 等路由重定向（/ → /tags）落定。
    await tester.pumpAndSettle();
    expect(find.text('GitGeek'), findsOneWidget);
  });
}
