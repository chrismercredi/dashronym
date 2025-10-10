import 'package:dashronym/dashronym.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Text.dashronyms wraps strings with tooltip spans', (
    tester,
  ) async {
    final registry = AcronymRegistry({
      'API': 'Application Programming Interface',
    });
    final widget = const Text(
      'Our (API) is public.',
    ).dashronyms(registry: registry, config: const DashronymConfig());

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    expect(find.byType(AcronymInline), findsOneWidget);
  });

  testWidgets('Text.dashronyms preserves existing rich text', (tester) async {
    final original = Text.rich(
      const TextSpan(text: 'Hello'),
      textScaler: const TextScaler.linear(1.2),
    );

    final result = original.dashronyms(registry: AcronymRegistry({})) as Text;

    expect(result.data, isNull);
    expect(result.textSpan, same(original.textSpan));
    expect(result.textScaler, const TextScaler.linear(1.2));
  });
}
