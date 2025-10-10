/// Inline glossary utilities for expanding acronyms in Flutter text.
///
/// This library turns known acronyms into tappable, accessible tooltip cards
/// without breaking reading flow. It provides:
///
/// * [DashronymText] - a widget that renders a string with inline tooltips.
/// * [Text.dashronyms] - an extension for ergonomically parsing a [Text].
/// * Parsing helpers - see [DashronymParser] and [DashronymConfig].
/// * Theming - see [DashronymTheme] for underline, timing, and card styling.
/// * Localization - add [DashronymLocalizations.delegate] so tooltip messages
///   (labels, hints, close button) follow the active locale.
///
/// Quick start:
/// ```dart
/// // 1) Define your glossary.
/// final registry = AcronymRegistry({
///   'SDK': 'Software Development Kit',
///   'API': 'Application Programming Interface',
/// });
///
/// // 2a) Use the Text extension:
/// const Text('Install the (SDK) to use the API.')
///   .dashronyms(
///     registry: registry,
///     config: DashronymConfig(enableBareAcronyms: true), // enables bare ALL-CAPS
///     theme: DashronymTheme(underline: true),
///   );
///
/// // 2b) Or use the dedicated widget:
/// DashronymText(
///   'Install the (SDK) to use the API.',
///   registry: registry,
///   config: DashronymConfig(enableBareAcronyms: true),
///   theme: DashronymTheme(),
/// );
///
/// // 3) Wire up localization (typically in MaterialApp):
/// MaterialApp(
///   localizationsDelegates: const [
///     // ...existing delegates,
///     DashronymLocalizations.delegate,
///   ],
///   supportedLocales: const [Locale('en')], // plus any others you include
///   // ...
/// )
/// ```
///
/// Notes:
/// * Marker-wrapped acronyms are recognized per [DashronymConfig.acceptMarkers]
///   (e.g., `(SDK)`, `"API"`, `'API'`). When [DashronymConfig.enableBareAcronyms]
///   is `true`, bare ALL-CAPS words within length bounds also match.
/// * Tooltips announce show/hide events to assistive tech when localized
///   strings are available.
/// * Styling (underline, thickness, offsets, fade durations, card size) is
///   controlled via [DashronymTheme].
library;

export 'src/config.dart';
export 'src/dashronym_text.dart';
export 'src/inline.dart';
export 'src/localizations.dart';
export 'src/lru.dart';
export 'src/parser.dart';
export 'src/registry.dart';
export 'src/text_extension.dart';
export 'src/theme.dart';
export 'src/tooltip_card.dart';
