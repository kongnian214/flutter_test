import 'package:lcs1/presentation/app/aurora_showcase_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Festival showcase renders headline and countdown', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: AuroraShowcaseApp()));

    expect(find.textContaining('氛围控制台'), findsOneWidget);
    expect(find.text('节日倒计时'), findsOneWidget);
  });
}
