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
}
