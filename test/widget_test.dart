import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App title renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('SkillConnect'))),
      ),
    );

    expect(find.text('SkillConnect'), findsOneWidget);
  });
}
