import 'package:dashronym/dashronym.dart';
import 'package:dashronym/src/inline.dart';
import 'package:dashronym/src/parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashronyms extension swaps markers for widget spans', (
    tester,
  ) async {
    final registry = AcronymRegistry({
      'SDK': 'Software Development Kit',
      'API': 'Application Programming Interface',
    });

    final spans = DashronymParser(
      registry: registry,
      config: const DashronymConfig(),
      theme: const DashronymTheme(),
      baseStyle: const TextStyle(),
    ).parseToSpans('This (SDK) exposes a stable (API).');
    expect(spans.whereType<WidgetSpan>().length, 2);

    final widget = const Text(
      'This (SDK) exposes a stable (API).',
    ).dashronyms(registry: registry);

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    expect(find.byType(AcronymInline), findsNWidgets(2));
  });
}
