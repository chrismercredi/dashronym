import 'package:dashronym/dashronym.dart';
import 'package:flutter/material.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final registry = AcronymRegistry({
      'SDK': 'Software Development Kit',
      'API': 'Application Programming Interface',
      'CLI': 'Command Line Interface',
      'FFI': 'Foreign Function Interface',
      'IDE': 'Integrated Development Environment',
      'LSP': 'Language Server Protocol',
      'UI': 'User Interface',
      'AOT': 'Ahead Of Time',
    });
    const config = DashronymConfig(enableBareAcronyms: true);
    const accentTheme = DashronymTheme(
      decorationStyle: TextDecorationStyle.wavy,
      cardWidth: 280,
      hoverShowDelay: Duration(milliseconds: 100),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('dashronym demo')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Inline Acronym Glossary for Flutter Documentation',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Hover or tap the highlighted acronyms to learn how dashronym augments Flutter prose with contextual glossary cards.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Abstract',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This brief article demonstrates how the dashronym plugin embeds interactive glossary entries directly in Flutter copy. '
              'By annotating acronyms such as (SDK) and (API), authors ensure both new and expert readers share a precise vocabulary while staying within the narrative flow.',
              style: Theme.of(context).textTheme.bodyMedium,
            ).dashronyms(
              registry: registry,
              config: config,
              theme: accentTheme,
            ),
            const SizedBox(height: 24),
            Text(
              'Method',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Authors draft prose as ordinary Flutter `Text` widgets, then call `.dashronyms()` to transform matching tokens into actionable overlays. '
              'dashronym parses for marked forms like (FFI) as well as bare ALL-CAPS phrases, injecting `WidgetSpan` entries that open rich cards describing each acronym.',
              style: Theme.of(context).textTheme.bodyMedium,
            ).dashronyms(
              registry: registry,
              config: config,
            ),
            const SizedBox(height: 24),
            Text(
              'Discussion',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Because dashronym cooperates with existing (UI) theming, documentation teams can mirror house styles or emphasize glossary triggers with custom underline treatments. '
              'Tooling such as project (CLI)s and (IDE) previews benefit as well, since the generated spans remain standard Flutter widgets.',
              style: Theme.of(context).textTheme.bodyMedium,
            ).dashronyms(
              registry: registry,
              config: config,
            ),
            const SizedBox(height: 24),
            Text(
              'Explicit widget',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DashronymText(
              'In standalone contexts, `DashronymText` offers the same parsing pipeline without relying on the extension helper. '
              'This is useful for reusable molecules inside component libraries or onboarding flows that explore topics like (LSP) support, (AOT) builds, and advanced (SDK) distribution strategies.',
              registry: registry,
              config: config,
              theme: const DashronymTheme(
                underline: false,
                cardWidth: 220,
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Conclusion',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'dashronym keeps Flutter documentation concise without sacrificing clarity. Pair it with your favorite (IDE) or static site generator, and every reader gains glossary grade insight at the exact point of need.',
              style: Theme.of(context).textTheme.bodyMedium,
            ).dashronyms(
              registry: registry,
              config: config,
              theme: const DashronymTheme(
                underline: true,
                decorationThickness: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
