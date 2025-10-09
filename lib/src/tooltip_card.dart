import 'package:flutter/material.dart';

import 'localizations.dart';
import 'theme.dart';

/// A tooltip card that surfaces an acronym's description.
///
/// Builds a themed [ListTile] with localized semantics and a close button that
/// dismisses the overlay when activated.
class DashronymTooltipCard extends StatelessWidget {
  const DashronymTooltipCard({
    super.key,
    required this.acronym,
    required this.description,
    required this.theme,
    required this.onClose,
  });

  /// The acronym being described.
  final String acronym;

  /// The human-readable description of the acronym.
  final String description;

  /// Theme data used to style the tooltip.
  final DashronymTheme theme;

  /// Invoked when the close button is triggered.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final strings = DashronymLocalizations.of(context);

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
