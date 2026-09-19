import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';

void main() {
  testWidgets('gUSo app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const GusoApp());

    expect(find.text('gUSo'), findsOneWidget);
  });
}