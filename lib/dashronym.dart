/// Inline glossary utilities for expanding acronyms in Flutter text.
///
/// Provides [DashronymText], the [Text.dashronyms] extension, parsing helpers,
/// theming, and localization delegates. Add [DashronymLocalizations.delegate]
/// to your app so tooltip messaging follows the active locale.
///
/// ```dart
/// final registry = AcronymRegistry({'SDK': 'Software Development Kit'});
/// final widget = const Text('Our (SDK) is stable.').dashronyms(
///   registry: registry,
///   config: const DashronymConfig(enableBareAcronyms: true),
/// );
/// ```
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
