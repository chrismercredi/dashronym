import 'package:flutter/material.dart';

import 'localizations.dart';
import 'theme.dart';

/// A compact, accessible tooltip card displaying an acronym and its description.
///
/// Renders a themed [ListTile] inside a [Material] surface with a close button.
/// Semantics are localized via [DashronymLocalizations] and exposed as a live
/// region so screen readers announce updates when the tooltip appears.
///
/// Typical usage (shown by an overlay controller, e.g., [AcronymInline]):
/// ```dart
/// DashronymTooltipCard(
///   acronym: 'SDK',
///   description: 'Software Development Kit',
///   theme: const DashronymTheme(),
///   onClose: () => overlayEntry.remove(),
/// )
/// ```
class DashronymTooltipCard extends StatelessWidget {
  /// Creates a tooltip card describing [acronym] with the given [description].
  ///
  /// Visuals and layout come from [theme]. The [onClose] callback is invoked
  /// when the trailing close button is activated.
  const DashronymTooltipCard({
    super.key,
    required this.acronym,
    required this.description,
    required this.theme,
    required this.onClose,
  });

  /// The acronym being described (e.g., `"API"`).
  final String acronym;

  /// The human-readable description shown under the title.
  final String description;

  /// Style, layout, and iconography for the card.
  final DashronymTheme theme;

  /// Called when the close button is pressed.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final strings = DashronymLocalizations.of(context);

    // Resolve colors and text styles from theme or ambient ThemeData.
    final iconColor =
        theme.cardIconColor ?? Theme.of(context).colorScheme.primary;
    final titleStyle =
        theme.cardTitleStyle ??
        Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    final subtitleStyle =
        theme.cardSubtitleStyle ?? Theme.of(context).textTheme.bodyMedium;

    return Semantics(
      container: true,
      liveRegion: true,
      label: strings.tooltipLabel(acronym),
      value: description,
      child: Material(
        elevation: theme.cardElevation,
        borderRadius: BorderRadius.circular(theme.cardBorderRadius),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: theme.cardWidth),
          child: Padding(
            padding: theme.cardPadding,
            child: ListTile(
              leading: Icon(theme.cardIcon, color: iconColor),
              title: Text(acronym, style: titleStyle),
              subtitle: Text(description, style: subtitleStyle),
              trailing: IconButton(
                tooltip: strings.closeButtonTooltip(acronym),
                icon: Icon(theme.cardCloseIcon, color: iconColor),
                onPressed: onClose,
              ),
              contentPadding: theme.cardContentPadding,
              minLeadingWidth: theme.cardMinLeadingWidth,
            ),
          ),
        ),
      ),
    );
  }
}
