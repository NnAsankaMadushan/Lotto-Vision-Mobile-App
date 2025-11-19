import 'package:flutter_test/flutter_test.dart';
import 'package:lotto_vision/main.dart';

void main() {
  testWidgets('LottoVision app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LottoVisionApp());

    // Verify that the app title is present
    expect(find.text('LottoVision'), findsWidgets);
  });
}
