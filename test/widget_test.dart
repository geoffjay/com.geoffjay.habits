import 'package:flutter_test/flutter_test.dart';
import 'package:habits/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitsApp());
    await tester.pumpAndSettle();
  });
}
