import 'dart:ui' show PointerDeviceKind;

import 'package:dashronym/dashronym.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _testHarness(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      DashronymLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: DashronymLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

DashronymTheme _theme() => const DashronymTheme(enableHover: false);

void main() {
  testWidgets('AcronymInline toggles tooltip via pointer and keyboard', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      _testHarness(
        FocusTraversalGroup(
          child: AcronymInline(
            acronym: 'SDK',
            description: 'Software Development Kit',
            theme: _theme(),
            textStyle: const TextStyle(),
          ),
        ),
      ),
    );

    final trigger = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'SDK' &&
          widget.style?.decoration == TextDecoration.underline,
    );
    expect(trigger, findsOneWidget);

    await tester.tap(trigger);
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsOneWidget);
    expect(find.byType(ScaleTransition), findsWidgets);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byType(DashronymTooltipCard), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byType(DashronymTooltipCard), findsNothing);

    final semanticsFinder = find.bySemanticsLabel('SDK').first;
    final semanticsNode = tester.getSemantics(semanticsFinder);
    expect(semanticsNode.hasFlag(SemanticsFlag.isButton), isTrue);

    semantics.dispose();
  });

  testWidgets('Tooltip repositions to remain within the viewport', (
    tester,
  ) async {
    final binding = tester.binding;
    final originalLogicalSize =
        binding.window.physicalSize / binding.window.devicePixelRatio;

    await binding.setSurfaceSize(const Size(220, 320));
    addTearDown(() async {
      await binding.setSurfaceSize(originalLogicalSize);
    });

    await tester.pumpWidget(
      _testHarness(
        AcronymInline(
          acronym: 'CLI',
          description: 'Command Line Interface',
          theme: _theme(),
          textStyle: const TextStyle(),
        ),
      ),
    );

    await tester.tap(find.text('CLI'));
    await tester.pumpAndSettle();

    final cardFinder = find.byType(DashronymTooltipCard);
    expect(cardFinder, findsOneWidget);

    final screenSize =
        binding.window.physicalSize / binding.window.devicePixelRatio;
    final topLeft = tester.getTopLeft(cardFinder);
    final topRight = tester.getTopRight(cardFinder);
    final bottomLeft = tester.getBottomLeft(cardFinder);

    expect(topLeft.dx, greaterThanOrEqualTo(0));
    expect(topRight.dx, lessThanOrEqualTo(screenSize.width));
    expect(topLeft.dy, greaterThanOrEqualTo(0));
    expect(bottomLeft.dy, lessThanOrEqualTo(screenSize.height));
  });

  testWidgets('Hover shows and hides tooltip when enabled', (tester) async {
    const hoverTheme = DashronymTheme(
      enableHover: true,
      hoverShowDelay: Duration(milliseconds: 50),
      hoverHideDelay: Duration(milliseconds: 50),
    );

    await tester.pumpWidget(
      _testHarness(
        AcronymInline(
          acronym: 'UI',
          description: 'User Interface',
          theme: hoverTheme,
          textStyle: const TextStyle(),
        ),
      ),
    );

    final trigger = find.text('UI');
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    await gesture.moveTo(tester.getCenter(trigger));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsOneWidget);

    await gesture.moveTo(Offset.zero);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsNothing);
    await gesture.removePointer();
  });

  testWidgets('Opening one tooltip hides any previously open tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testHarness(
        FocusTraversalGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AcronymInline(
                acronym: 'SDK',
                description: 'Software Development Kit',
                theme: _theme(),
                textStyle: const TextStyle(),
              ),
              const SizedBox(height: 12),
              AcronymInline(
                acronym: 'API',
                description: 'Application Programming Interface',
                theme: _theme(),
                textStyle: const TextStyle(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text('Software Development Kit'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text('Software Development Kit'), findsNothing);
    expect(find.text('Application Programming Interface'), findsOneWidget);
  });

  testWidgets('AcronymInline uses custom tooltipBuilder when provided', (
    tester,
  ) async {
    final tooltipKey = GlobalKey();

    await tester.pumpWidget(
      _testHarness(
        AcronymInline(
          acronym: 'API',
          description: 'Application Programming Interface',
          theme: _theme(),
          textStyle: const TextStyle(),
          tooltipBuilder: (context, details) {
            return GestureDetector(
              key: tooltipKey,
              onTap: details.hideTooltip,
              child: Material(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(details.description),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('API'));
    await tester.pumpAndSettle();

    expect(find.byKey(tooltipKey), findsOneWidget);

    await tester.tap(find.byKey(tooltipKey));
    await tester.pumpAndSettle();

    expect(find.byKey(tooltipKey), findsNothing);
  });

  testWidgets('AcronymInline reacts to updates, metrics changes, and scrolls', (
    tester,
  ) async {
    final themeNotifier = ValueNotifier(
      const DashronymTheme(
        enableHover: false,
        tooltipFadeDuration: Duration(milliseconds: 120),
        tooltipMinWidth: 140,
        hoverShowDelay: Duration(milliseconds: 10),
        hoverHideDelay: Duration(milliseconds: 20),
      ),
    );

    var useScroll = true;
    late StateSetter toggleLayout;

    await tester.pumpWidget(
      _testHarness(
        StatefulBuilder(
          builder: (context, setState) {
            toggleLayout = setState;
            return ValueListenableBuilder<DashronymTheme>(
              valueListenable: themeNotifier,
              builder: (context, theme, _) {
                final inline = AcronymInline(
                  key: const ValueKey('inline'),
                  acronym: 'SDK',
                  description: 'Software Development Kit',
                  theme: theme,
                  textStyle: const TextStyle(),
                );

                Widget child;
                if (useScroll) {
                  child = SizedBox(
                    height: 200,
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: [
                        const SizedBox(height: 16),
                        inline,
                        const SizedBox(height: 320),
                      ],
                    ),
                  );
                } else {
                  child = inline;
                }

                return FocusTraversalGroup(child: child);
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('inline')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(DashronymTooltipCard), findsOneWidget);

    themeNotifier.value = themeNotifier.value.copyWith(
      tooltipFadeDuration: const Duration(milliseconds: 60),
      hoverHideDelay: const Duration(milliseconds: 30),
    );
    await tester.pump();

    tester.binding.handleMetricsChanged();
    await tester.pump();

    await tester.drag(find.byType(ListView), const Offset(0, -60));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsNothing);

    toggleLayout(() {
      useScroll = false;
    });
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('inline')));
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsOneWidget);

    final state = tester.state(find.byKey(const ValueKey('inline')));
    (state as dynamic).debugRemoveEntry();
    await tester.tap(find.byKey(const ValueKey('inline')));
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsNothing);

    await tester.tap(find.byKey(const ValueKey('inline')));
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsNothing);
  });

  testWidgets('AcronymInline hides tooltip on orientation change', (
    tester,
  ) async {
    final binding = tester.binding;
    final originalLogicalSize =
        binding.window.physicalSize / binding.window.devicePixelRatio;

    await binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() async {
      await binding.setSurfaceSize(originalLogicalSize);
    });

    await tester.pumpWidget(
      _testHarness(
        AcronymInline(
          acronym: 'SDK',
          description: 'Software Development Kit',
          theme: _theme(),
          textStyle: const TextStyle(),
        ),
      ),
    );

    await tester.tap(find.text('SDK'));
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsOneWidget);

    await binding.setSurfaceSize(const Size(640, 360));
    binding.handleMetricsChanged();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(DashronymTooltipCard), findsNothing);
  });

  testWidgets('Scrolling dismisses a visible tooltip', (tester) async {
    final controller = ScrollController();

    await tester.pumpWidget(
      _testHarness(
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              children: [
                const SizedBox(height: 16),
                AcronymInline(
                  acronym: 'SDK',
                  description: 'Software Development Kit',
                  theme: _theme(),
                  textStyle: const TextStyle(),
                ),
                const SizedBox(height: 400),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('SDK'));
    await tester.pumpAndSettle();
    expect(find.byType(DashronymTooltipCard), findsOneWidget);

    controller.jumpTo(30);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(DashronymTooltipCard), findsNothing);
  });
}
