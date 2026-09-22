import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_geek/main.dart';

void main() {
  testWidgets('GitGeek home renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump();
    expect(find.text('GitGeek'), findsOneWidget);
  });
}
