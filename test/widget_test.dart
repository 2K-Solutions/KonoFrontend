import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:konofrontend/main.dart';

void main() {
  testWidgets('shows role selection screen on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KonoApp()));
    await tester.pumpAndSettle();

    expect(find.text('I AM AN OWNER'), findsOneWidget);
    expect(find.text('I AM A WORKER'), findsOneWidget);
  });
}
