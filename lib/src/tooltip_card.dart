/// Tooltip card widget used by Dashronym inline controls.
///
/// The card now caps its width using the viewport and theme-provided limits,
/// letting the subtitle wrap naturally across multiple lines while keeping the
/// title constrained to a single line with ellipsis. This maintains a tidy
/// layout without bespoke text measurement logic.
library;

import 'package:flutter/material.dart';

import 'localizations.dart';
import 'theme.dart';
import 'tooltip_constraints.dart';

/// A compact, accessible tooltip card displaying an acronym and its description.
///
/// ### Sizing rules
/// The card caps its width to the tightest available limit from the viewport or
/// theme and otherwise shrink-wraps to the intrinsic width of its content,
/// letting the description wrap with natural word breaks. When
/// [DashronymTheme.tooltipMaxWidth] is set, it overrides the portrait fallback
/// to [DashronymTheme.cardWidth]. The acronym stays a single trimmed line.
///
/// ### Example
/// ```dart
/// DashronymTooltipCard(
///   acronym: 'SDK',
///   description: 'Software Development Kit',
///   theme: theme,
///   onClose: () => Navigator.of(context).maybePop(),
/// )
/// ```
class DashronymTooltipCard extends StatelessWidget {
  /// Creates a [DashronymTooltipCard].
  ///
  /// See the class docs for sizing rules and an example.
  const DashronymTooltipCard({
    super.key,
    required this.acronym,
    required this.description,
    required this.theme,
    required this.onClose,
  });

  /// The short acronym shown as the title (e.g., `"SDK"`).
  final String acronym;

  /// The full definition associated with [acronym].
  final String description;

  /// The effective theme controlling spacing, radii, typography and caps.
  final DashronymTheme theme;

  /// Invoked when the trailing close button is pressed.
  final VoidCallback onClose;

  /// Builds the Material tooltip card.
  @override
  Widget build(BuildContext context) {
    final strings = DashronymLocalizations.of(context);

    final mq = MediaQuery.maybeOf(context);
    final iconColor =
        theme.cardIconColor ?? Theme.of(context).colorScheme.primary;
    final titleStyle =
        theme.cardTitleStyle ??
        Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    final subtitleStyle =
        theme.cardSubtitleStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(letterSpacing: 0);

    return Semantics(
      container: true,
      liveRegion: true,
      label: strings.tooltipLabel(acronym),
      value: description,
      child: Material(
        elevation: theme.cardElevation,
        borderRadius: BorderRadius.circular(theme.cardBorderRadius),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mqForBuilder = MediaQuery.maybeOf(context);
            final tooltipConstraints = TooltipConstraintsResolver.resolve(
              constraints: constraints,
              mediaQuery: mqForBuilder ?? mq,
              theme: theme,
            );
            return ConstrainedBox(
              constraints: tooltipConstraints,
              child: Padding(
                padding: theme.cardPadding,
                child: ListTile(
                  leading: Icon(theme.cardIcon, color: iconColor),
                  title: Text(
                    acronym,
                    style: titleStyle,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    textWidthBasis: TextWidthBasis.longestLine,
                  ),
                  subtitle: Text(
                    description,
                    style: subtitleStyle,
                    softWrap: true,
                  ),
                  trailing: IconButton(
                    tooltip: strings.closeButtonTooltip(acronym),
                    icon: Icon(theme.cardCloseIcon, color: iconColor),
                    onPressed: onClose,
                  ),
                  contentPadding: theme.cardContentPadding,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
