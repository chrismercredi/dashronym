import 'package:dashronym/dashronym.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DashronymText renders widget spans with provided text scaler', (
    tester,
  ) async {
    final widget = DashronymText(
      'Our (SDK) is stable.',
      registry: AcronymRegistry({'SDK': 'Software Development Kit'}),
      config: const DashronymConfig(),
      theme: const DashronymTheme(),
      textScaler: const TextScaler.linear(1.5),
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    final richText = tester.widgetList<RichText>(find.byType(RichText)).first;
    final span = richText.text as TextSpan;

    expect(richText.textScaler, const TextScaler.linear(1.5));
    expect(span.children?.whereType<WidgetSpan>().length, 1);
  });

  testWidgets(
    'DashronymText merges inherited style and honors semanticsLabel',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final registry = AcronymRegistry({'SDK': 'Software Development Kit'});

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(boldText: true),
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 12),
              child: Scaffold(
                body: DashronymText(
                  'This SDK is powerful.',
                  registry: registry,
                  config: const DashronymConfig(enableBareAcronyms: true),
                  theme: const DashronymTheme(),
                  semanticsLabel: 'SDK definition label',
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final richText = tester.widget<RichText>(find.byType(RichText).first);
      expect(richText.text.style?.fontWeight, FontWeight.bold);

      final semanticsNode = tester.getSemantics(
        find.bySemanticsLabel('SDK definition label'),
      );
      expect(semanticsNode.label, 'SDK definition label');

      semantics.dispose();
    },
  );

  testWidgets('DashronymText respects non-inherited style', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashronymText(
            'SDK docs',
            registry: AcronymRegistry({'SDK': 'Software Development Kit'}),
            style: const TextStyle(inherit: false, fontSize: 18),
            config: const DashronymConfig(),
            theme: const DashronymTheme(),
          ),
        ),
      ),
    );

    final richText = tester.widget<RichText>(find.byType(RichText));
    expect(richText.text.style?.fontSize, 18);
  });
}
