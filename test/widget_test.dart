import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironforge/src/app.dart';

void main() {
  testWidgets('IronForge home screen renders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: IronForgeApp()));

    expect(find.text('IronForge'), findsOneWidget);
    expect(find.text('START WORKOUT'), findsOneWidget);
  });

  testWidgets('Workout logger opens from home', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: IronForgeApp()));

    await tester.tap(find.text('START WORKOUT'));
    await tester.pumpAndSettle();

    expect(find.text('Live Workout'), findsOneWidget);
    expect(find.text('QUICK ADD EXERCISE'), findsOneWidget);
  });
}
