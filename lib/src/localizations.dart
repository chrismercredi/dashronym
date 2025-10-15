import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Localized strings used by dashronym widgets.
///
/// Provides phrases for tooltips, semantics, and announcements. Supply the
/// bundled [delegate] alongside Flutter's built-in localization delegates to
/// enable translations.
class DashronymLocalizations {
  /// Creates localization strings scoped to the given [locale].
  DashronymLocalizations(this.locale);

  /// The locale associated with these strings.
  final Locale locale;

  /// The locales supported by dashronym translations.
  static const supportedLocales = <Locale>[Locale('en')];

  /// The localization delegate that loads [DashronymLocalizations].
  static const LocalizationsDelegate<DashronymLocalizations> delegate =
      _DashronymLocalizationsDelegate();

  /// The localization resources for [context], falling back to English.
  ///
  /// Returns the ambient instance created by [delegate], or a new
  /// [DashronymLocalizations] configured for `'en'` when not found.
  static DashronymLocalizations of(BuildContext context) {
    final result = Localizations.of<DashronymLocalizations>(
      context,
      DashronymLocalizations,
    );
    return result ?? DashronymLocalizations(const Locale('en'));
  }

  /// The tooltip message shown beside an inline acronym trigger.
  ///
  /// The [acronym] and [description] are interpolated into a multi-line
  /// message so screen readers expose both parts together.
  String tooltipMessage(String acronym, String description) =>
      'Show definition for $acronym.\n$description';

  /// The semantics hint read before showing the tooltip.
  String semanticsHintShow(String acronym) =>
      'Double tap to show definition for $acronym.';

  /// The semantics hint read while the tooltip is visible.
  String semanticsHintHide(String acronym) =>
      'Double tap to hide definition for $acronym.';

  /// The live region announcement used when the tooltip becomes visible.
  String announceTooltipShown(String acronym) =>
      'Showing definition for $acronym.';

  /// The live region announcement used after dismissing the tooltip.
  String announceTooltipHidden(String acronym) =>
      'Closed definition for $acronym.';

  /// The semantics label for the temporary dismiss layer.
  String semanticsBarrierLabel(String acronym) =>
      'Hide definition for $acronym.';

  /// The tooltip text used on the close button.
  String closeButtonTooltip(String acronym) => 'Hide definition for $acronym';

  /// The semantics label applied to the close button.
  String closeButtonLabel(String acronym) => 'Close definition for $acronym';

  /// The semantics label applied to the tooltip card container.
  String tooltipLabel(String acronym) => 'Definition for $acronym';
}

/// A delegate that synchronously loads [DashronymLocalizations] instances.
class _DashronymLocalizationsDelegate
    extends LocalizationsDelegate<DashronymLocalizations> {
  const _DashronymLocalizationsDelegate();

  @override
  /// Whether this delegate supports [locale].
  bool isSupported(Locale locale) => true;

  @override
  /// Loads localization resources for [locale].
  Future<DashronymLocalizations> load(Locale locale) =>
      SynchronousFuture(DashronymLocalizations(locale));

  @override
  /// Whether this delegate should reload when [old] changes.
  bool shouldReload(_DashronymLocalizationsDelegate old) => false;
}
