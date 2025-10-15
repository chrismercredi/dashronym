# dashronym

dashronym creates inline glossary cards for acronyms that appear inside your Flutter text widgets. Authors can mark acronyms like `(SDK)` or rely on bare ALL-CAPS matches, and the extension transforms them into tappable overlays that surface full descriptions without breaking reading flow.

## Features

- `Text.dashronyms()` extension that swaps matching tokens for interactive `WidgetSpan`s.
- `DashronymText` widget for composing standalone rich text blocks.
- Configurable matching (`DashronymConfig`) with optional bare acronym detection.
- Theme controls (`DashronymTheme`) for underline styles, hover behaviour, hide delays, and card layout with fade animations.
- Lightweight LRU caching to avoid reparsing unchanged strings.
- Comprehensive DartDoc coverage so IDE tooltips describe every public helper.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  dashronym: ^0.0.8
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

## Configuration

| Class | Purpose |
|-------|---------|
| `AcronymRegistry` | Stores acronym -> description pairs with optional case-insensitivity. |
| `DashronymConfig` | Enables bare matches and custom marker patterns or length constraints. |
| `DashronymTheme`  | Adjusts underline appearance, hover behaviour, hide delays, fade duration, and card layout. |

## Contributing

Contributions, issues, and feature requests are welcome! Please open an issue on the [GitHub tracker](https://github.com/chrismercredi/dashronym/issues).
