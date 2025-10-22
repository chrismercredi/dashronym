# dashronym

dashronym creates inline glossary cards for acronyms that appear inside your Flutter text widgets. Authors can mark acronyms like `(SDK)` or rely on bare ALL-CAPS matches, and the extension transforms them into tappable overlays that surface full descriptions without breaking reading flow.

## Features

- Ready-to-use defaults with accessible semantics, keyboard support, and single-overlay focus management.
- `Text.dashronyms()` extension that swaps matching tokens for interactive `WidgetSpan`s.
- `DashronymText` widget for composing standalone rich text blocks.
- Configurable matching (`DashronymConfig`) with optional bare acronym detection.
- Theme controls (`DashronymTheme`) for underline styles, hover behaviour, fade + scale animations, and width constraints with `copyWith` / `merge`.
- Tooltip cards shrink-wrap to their content while honoring viewport, theme caps, and orientation-specific guardrails (360 px portrait / 600 px landscape) so descriptions wrap naturally without manual text measurement.
- Edge-aware overlays that respect safe areas and keep an 8 px gutter on both sides, even when clamped or using a custom tooltip builder.
- Optional `tooltipBuilder` hook for rendering custom tooltip content while reusing the overlay lifecycle.
- Lightweight LRU caching to avoid reparsing unchanged strings.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  dashronym: ^0.0.9
```

Run `flutter pub get` to pull in the dependency.

## Quick start

```dart
final registry = AcronymRegistry({
  'SDK': 'Software Development Kit',
  'API': 'Application Programming Interface',
  'CLI': 'Command Line Interface',
});

class OverviewText extends StatelessWidget {
  const OverviewText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Our (SDK) exposes a lightweight (API) for CLI tooling.',
    ).dashronyms(
      registry: registry,
      config: const DashronymConfig(enableBareAcronyms: true),
    );
  }
}
```

Take a look at the `/example` app for a longer, article-style demonstration that highlights theming and advanced usage.

## Customization

You can tailor the visuals or behaviour by overriding the theme, adjusting parsing rules, or supplying a custom tooltip builder:

```dart
const accentTheme = DashronymTheme(
  hoverShowDelay: Duration(milliseconds: 120),
  tooltipScaleBegin: 0.9,
  tooltipScaleEnd: 1.05,
);

const customConfig = DashronymConfig(
  enableBareAcronyms: true,
  acceptMarkers: ['«»'],
);

Text('Tap «SDK» to learn more.')
    .dashronyms(registry: registry, config: customConfig, theme: accentTheme);

Text('«API» tooltip with branded content.')
    .dashronyms(
      registry: registry,
      config: customConfig,
      tooltipBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Card(
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
        );
      },
    );
```

The `packagetester/tester` app shows the defaults alongside themed variants so you can compare configurations quickly. Custom builders automatically inherit the active theme’s width constraints, so bespoke surfaces stay within the edge gutter while still expanding vertically for lengthy copy.

## Configuration

| Class | Purpose |
|-------|---------|
| `AcronymRegistry` | Stores acronym -> description pairs with optional case-insensitivity. |
| `DashronymConfig` | Enables bare matches and custom marker patterns or length constraints. |
| `DashronymTheme`  | Adjusts underline appearance, hover/animation behaviour, width constraints, and can be composed via `copyWith` / `merge`. |
| `DashronymTooltipBuilder` + `AcronymTooltipDetails` | Provide custom tooltip widgets while keeping the inline trigger behaviour and lifecycle. |

## Contributing

Contributions, issues, and feature requests are welcome! Please open an issue on the [GitHub tracker](https://github.com/chrismercredi/dashronym/issues).

When tweaking visuals, run `flutter test --update-goldens test/inline_golden_test.dart` to refresh the tooltip goldens.
