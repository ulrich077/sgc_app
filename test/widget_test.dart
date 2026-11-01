import 'package:flutter_test/flutter_test.dart';
import 'package:sgc/main.dart';

void main() {
  testWidgets('SgcApp renders', (WidgetTester tester) async {
    await tester.pumpWidget(const SgcApp());
    expect(find.textContaining('SGC'), findsWidgets);
  });
}
