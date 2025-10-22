import 'package:dashronym/dashronym.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Entry point for the demo application.
///
/// The showcase surfaces a sequence of sections that highlight:
/// * Out-of-the-box usage (no configuration required).
/// * Theme-based customization (animation tweaks, card styling).
/// * Full tooltip replacement via `tooltipBuilder`.
/// * Behaviour when content extends beyond the initial viewport.
void main() => runApp(const DashronymShowcase());

class DashronymShowcase extends StatelessWidget {
  const DashronymShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the glossary once so every section reads from the same definitions.
    final registry = AcronymRegistry({
      'SDK': 'Software Development Kit',
      'API': 'Application Programming Interface',
      'CLI': 'Command Line Interface',
      'FFI': 'Foreign Function Interface',
      'IDE': 'Integrated Development Environment',
      'LSP': 'Language Server Protocol',
      'UI': 'User Interface',
      'AOT': 'Ahead Of Time compilation',
    });
    const config = DashronymConfig(
      enableBareAcronyms: true,
      acceptMarkers: ['«»'],
    );

    // Example theme that focuses on animation behaviour.
    const animationTheme = DashronymTheme(
      tooltipFadeDuration: Duration(milliseconds: 220),
      tooltipScaleBegin: 0.92,
      tooltipScaleEnd: 1.05,
      tooltipScaleInCurve: Curves.easeOutBack,
      tooltipScaleOutCurve: Curves.easeIn,
    );

    // Example theme that focuses on card surface appearance.
    const themedSurface = DashronymTheme(
      underline: true,
      decorationThickness: 1.5,
      cardElevation: 10,
      cardIcon: Icons.book_outlined,
      cardCloseIcon: Icons.close_rounded,
      cardIconColor: Colors.deepPurple,
      cardTitleStyle: TextStyle(fontWeight: FontWeight.bold),
      tooltipOffset: Offset(0, 8),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      localizationsDelegates: const [
        DashronymLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: DashronymLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(title: const Text('dashronym showcase')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AccessibleHeader(
              title: 'Drop-in defaults',
              subtitle:
                  'No theme overrides — demonstrates the base behaviour out of the box.',
            ),
            Text(
              'Authors draft Flutter documentation as ordinary `Text` widgets, then call '
              '`.dashronyms()` to transform tokens like SDK into tappable overlays.',
              style: Theme.of(context).textTheme.bodyMedium,
            ).dashronyms(registry: registry, config: config),
            const SizedBox(height: 12),
            Text(
              'Scroll further down the page to verify off-screen acronyms continue to resolve '
              'correctly once they re-enter the viewport. The default theme keeps typography '
              'intact while the trigger underline signals interactive guidance.',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: 32),
            _AccessibleHeader(
              title: 'Customized animations',
              subtitle:
                  'Tweaked fade + scale curves and durations via DashronymTheme.',
            ),
            Text(
              'Hover over «CLI» or «IDE» to see a playful scale animation produced by custom '
              'curves.',
              style: Theme.of(context).textTheme.bodyMedium,
            ).dashronyms(
              registry: registry,
              config: config,
              theme: animationTheme,
            ),
            const SizedBox(height: 12),
            Text(
              'These animation settings still respect screen readers and keyboard interaction, so '
              'users tabbing between elements experience the same reveal without jitter.',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: 32),
            _AccessibleHeader(
              title: 'Customized tooltip surface',
              subtitle:
                  'Card sizing, elevation, iconography, offsets, and built-in edge gutters.',
            ),
            Text(
              'Design teams can adjust underline styling, tooltip width, and icons without '
              'rewriting any logic. Tap «FFI» or «LSP» to see the modified surface.',
              style: Theme.of(context).textTheme.bodyMedium,
            ).dashronyms(
              registry: registry,
              config: config,
              theme: themedSurface,
            ),
            const SizedBox(height: 12),
            Text(
              'Try rotating or resizing the window: the tooltip recalibrates safe areas, keeps an '
              '8 px gutter on both sides, and remains visible on phones, tablets, and desktops.',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: 32),
            _AccessibleHeader(
              title: 'Custom tooltip builder',
              subtitle:
                  'Supply your own widget while reusing overlay lifecycle, focus, and semantics.',
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                const Text('Our'),
                // Tooltip builder receives the details and a `hideTooltip` callback.
                AcronymInline(
                  acronym: 'UI',
                  description: 'User Interface',
                  theme: themedSurface,
                  textStyle: const TextStyle(
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.solid,
                    fontWeight: FontWeight.w500,
                  ),
                  tooltipBuilder: (context, details) => Semantics(
                    container: true,
                    label:
                        '${details.acronym} glossary card. Activate the close button to dismiss.',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        margin: EdgeInsets.zero,
                        color: Colors.indigo.shade50,
                        child: ListTile(
                          title: Text(details.acronym),
                          subtitle: Text(details.description),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: details.hideTooltip,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Text('flow embraces localization and accessibility.'),
              ],
            ),

            const SizedBox(height: 32),
            _AccessibleHeader(
              title: 'Standalone widget',
              subtitle:
                  'DashronymText offers the same parsing pipeline without the extension helper.',
            ),
            DashronymText(
              'Use DashronymText inside reusable components to highlight (AOT) flows and '
              '(SDK) distribution strategies.',
              registry: registry,
              config: config,
              theme: const DashronymTheme(underline: false),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Text(
              'Long-form content demo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Below is a block of prose that exceeds the initial viewport height so you can test '
              'scrolling behaviour. Hover and keyboard interactions should continue to operate '
              'even after you scroll away and back. The tooling references we use later—such as '
              'the Integrated Development Environment «IDE», the command-line interface «CLI», '
              'and Ahead Of Time (AOT) compilation—should feel natural in the narrative.',
              style: Theme.of(context).textTheme.bodyMedium,
            ).dashronyms(
              registry: registry,
              config: config,
              theme: themedSurface,
            ),
            const SizedBox(height: 12),
            Text(
              'When modern Flutter teams build cross-platform experiences, they often pair an IDE '
              'setup with automated CLI pipelines. That combination allows them to iterate '
              'quickly while keeping release artifacts deterministic. With dashronym in place, '
              'onboarding docs for new engineers can reference the same glossary inline without '
              'forcing readers to jump between pages. As your content expands, the lightweight '
              'LRU cache prevents repeated parsing of the same paragraphs, so infinite scrolling '
              'feeds and long-form articles still perform well.',
              style: Theme.of(context).textTheme.bodyMedium,
            ).dashronyms(
              registry: registry,
              config: config,
              theme: themedSurface,
            ),
            const SizedBox(height: 12),
            Text(
              'Continue scrolling to confirm that overlays collapse when dismissed and do not '
              'linger off-screen. The accessibility enhancements—debounced announcements, '
              'focus-based toggling, and single overlay enforcement—remain active regardless of '
              'how far down the article you travel. Edge-aware positioning now keeps tooltips off '
              'both sides of the viewport, even with custom builders.',
              style: Theme.of(context).textTheme.bodySmall,
            ).dashronyms(
              registry: registry,
              config: config,
              theme: themedSurface,
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple helper widget that renders section headings.
///
/// Using a widget instead of raw code keeps the example compact and ensures
/// consistent spacing and semantics across sections.
class _AccessibleHeader extends StatelessWidget {
  const _AccessibleHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
