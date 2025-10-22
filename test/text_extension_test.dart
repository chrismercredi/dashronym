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

  testWidgets('Text.dashronyms merges inherited style and bold text', (
    tester,
  ) async {
    final registry = AcronymRegistry({'SDK': 'Software Development Kit'});

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(boldText: true),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 14),
            child: Scaffold(
              body: const Text(
                'SDK launch successful',
              ).dashronyms(registry: registry),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    final richText = tester.widget<RichText>(find.byType(RichText));
    expect(richText.text.style?.fontWeight, FontWeight.bold);
  });

  testWidgets('Text.dashronyms keeps explicit non-inherited style', (
    tester,
  ) async {
    final registry = AcronymRegistry({'SDK': 'Software Development Kit'});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const Text(
            'SDK ready',
            style: TextStyle(inherit: false, fontSize: 22),
          ).dashronyms(registry: registry),
        ),
      ),
    );

    final richText = tester.widget<RichText>(find.byType(RichText));
    expect(richText.text.style?.fontSize, 22);
  });
}
