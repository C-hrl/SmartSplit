import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_split/main.dart';

void main() {
  testWidgets('Testing Side Menu Widgets', (WidgetTester tester) async {
    tester.pumpWidget(const App());

    final fileNameController = find.byKey(const ValueKey("exportFileDialog"));
    final confirmButton = find.byKey(const ValueKey("exportFileDialog"));

    await tester.enterText(fileNameController, "");
    await tester.tap(confirmButton);
    await tester.pump(); //rebuilding

    expect(find.text(""), findsOneWidget);
  });
}
