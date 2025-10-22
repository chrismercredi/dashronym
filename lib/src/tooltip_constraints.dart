import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Shared helpers for clamping tooltip content within the visible viewport.
///
/// The resolver is used by both the stock Dashronym tooltip card and any custom
/// tooltip builders supplied to `AcronymInline`. It projects the overlay, media
/// query and theme caps into a single [BoxConstraints] so tooltip content never
/// paints outside the window gutters.
class TooltipConstraintsResolver {
  const TooltipConstraintsResolver._(); // coverage:ignore-line

  /// Default outer gutter applied on either horizontal edge.
  static const double outerGutter = 8.0;

  /// Calculates width constraints that keep the tooltip inside the viewport.
  ///
  /// The algorithm considers:
  ///
  /// * the parent layout [constraints] (typically the overlay),
  /// * safe-area padding obtained from [mediaQuery], and
  /// * theme-provided caps on width (see [DashronymTheme.tooltipMaxWidth]).
  ///
  /// The returned constraints always have a `minWidth` that is `<= maxWidth`,
  /// collapsing the minimum when the available width is too tight for the
  /// theme-requested minimum.
  static BoxConstraints resolve({
    required BoxConstraints constraints,
    required MediaQueryData? mediaQuery,
    required DashronymTheme theme,
  }) {
    final padding = mediaQuery?.padding ?? EdgeInsets.zero;
    final screenWidth = mediaQuery?.size.width ?? double.infinity;
    final orientation = mediaQuery?.orientation ?? Orientation.portrait;

    final safeScreenWidth = screenWidth.isFinite
        ? screenWidth - padding.left - padding.right
        : double.infinity;
    double viewportCap = safeScreenWidth.isFinite
        ? safeScreenWidth - outerGutter * 2
        : double.infinity;
    if (viewportCap.isFinite && viewportCap < 0) {
      viewportCap = 0;
    }

    double overlayCap = constraints.maxWidth.isFinite
        ? constraints.maxWidth - outerGutter * 2
        : double.infinity;
    if (overlayCap.isFinite && overlayCap < 0) {
      overlayCap = 0;
    }

    final themeCap =
        theme.tooltipMaxWidth ??
        (orientation == Orientation.portrait
            ? theme.cardWidth
            : double.infinity);

    double maxWidth = double.infinity;
    for (final candidate in [viewportCap, overlayCap, themeCap]) {
      if (candidate.isFinite) {
        maxWidth = maxWidth.isFinite
            ? math.min(maxWidth, candidate)
            : candidate;
      }
    }
    if (maxWidth.isFinite && maxWidth < 0) {
      maxWidth = 0;
    }

    final orientationCap = orientation == Orientation.portrait ? 360.0 : 600.0;
    if (maxWidth.isFinite) {
      maxWidth = math.min(maxWidth, orientationCap);
    } else {
      maxWidth = orientationCap;
    }

    double minWidth = theme.tooltipMinWidth ?? 0;
    if (minWidth > 0 && maxWidth.isFinite && minWidth > maxWidth) {
      minWidth = maxWidth;
    }

    return BoxConstraints(
      minWidth: minWidth > 0 ? minWidth : 0,
      maxWidth: maxWidth.isFinite ? maxWidth : double.infinity,
    );
  }
}
