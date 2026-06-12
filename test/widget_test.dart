import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironforge/src/app.dart';

void main() {
  testWidgets('IronForge home screen renders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: IronForgeApp()));

    expect(find.text('IronForge'), findsOneWidget);
    expect(find.text('START WORKOUT'), findsOneWidget);
  });
}
