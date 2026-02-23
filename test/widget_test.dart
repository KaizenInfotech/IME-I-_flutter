import 'package:flutter_test/flutter_test.dart';

import 'package:touchbase_flutter/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('TouchBase Flutter'), findsOneWidget);
  });
}
