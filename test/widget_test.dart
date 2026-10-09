import 'package:flutter_test/flutter_test.dart';
import 'package:pindea/main.dart';

void main() {
  testWidgets('Pindea app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PindeaApp());
    await tester.pump();
    expect(find.text('Pindea'), findsOneWidget);
    expect(find.text('Quick Notes'), findsOneWidget);
    expect(find.text('All Notes'), findsOneWidget);
  });
}
