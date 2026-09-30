// A basic widget test for the Todo app.
// Run it with:  flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/main.dart';

void main() {
  testWidgets('Adding a todo shows it in the list', (WidgetTester tester) async {
    // Build the app and draw the first frame.
    await tester.pumpWidget(const TodoApp());

    // At the start there are no todos.
    expect(find.text('No Todos yet'), findsOneWidget);

    // Type a todo and tap "Add".
    await tester.enterText(find.byType(TextField), 'Buy milk');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pump();

    // The new todo is visible and the empty message is gone.
    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('No Todos yet'), findsNothing);
  });
}
