import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import 'localizations.dart';
import 'theme.dart';
import 'tooltip_card.dart';

/// An inline, tappable acronym that shows an accessible tooltip card.
///
/// When activated (tap/Enter/Space) or focused/hovered (if enabled), this
/// widget opens a Material overlay positioned near the inline text. The overlay
/// renders a small card (see [DashronymTooltipCard]) with the acronym and its
/// full [description]. It supports keyboard, screen reader, and pointer
/// interactions:
///
/// * Tap/click or activate (Enter/Space) to toggle the tooltip.
/// * Press Escape to dismiss.
/// * Hover show/hide is supported when [DashronymTheme.enableHover] is `true`.
/// * Screen readers receive announcements when the tooltip is shown/hidden.
///
/// The trigger text inherits [textStyle] and can be customized by
/// [DashronymTheme] (e.g., underline, thickness, fade durations, offsets).
///
/// Typical usage inside a `WidgetSpan`:
/// ```dart
/// Text.rich(
///   TextSpan(
///     children: [
///       const TextSpan(text: 'We use the '),
///       WidgetSpan(
///         alignment: PlaceholderAlignment.baseline,
///         baseline: TextBaseline.alphabetic,
///         child: AcronymInline(
///           acronym: 'SDK',
///           description: 'Software Development Kit',
///           theme: DashronymTheme.fallback(),
///           textStyle: DefaultTextStyle.of(context).style,
///         ),
///       ),
///       const TextSpan(text: ' for plugins.'),
///     ],
///   ),
/// )
/// ```
///
/// Semantics:
/// This widget exposes a button role with a dynamic hint (show/hide) and, when
/// open, sets [Semantics.value] to the [description]. It also uses
/// [SemanticsService.announce] for polite announcements.
///
/// Layout/overlay:
/// Uses a [CompositedTransformTarget]/[CompositedTransformFollower] pair to
/// position the tooltip relative to the inline text and flips horizontal
/// offseting for RTL via [TextDirection].
class AcronymInline extends StatefulWidget {
  /// Creates an inline acronym control that shows a tooltip when activated.
  const AcronymInline({
    super.key,
    required this.acronym,
    required this.description,
    required this.theme,
    required this.textStyle,
  });

  /// The acronym text shown inline (e.g., `"SDK"`).
  final String acronym;

  /// The descriptive text rendered inside the tooltip card.
  final String description;

  /// Visual and interaction parameters for the trigger and tooltip.
  ///
  /// See [DashronymTheme] for underline, decoration, timing, and offset options.
  final DashronymTheme theme;

  /// Base text style inherited from the surrounding span.
  ///
  /// The trigger style is derived from this plus any overrides in [theme].
  final TextStyle? textStyle;

  @override
  State<AcronymInline> createState() => _AcronymInlineState();
}

class _AcronymInlineState extends State<AcronymInline>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final LayerLink _link = LayerLink();
  final FocusNode _focusNode = FocusNode(debugLabel: 'DashronymInline');

  OverlayEntry? _entry;
  bool _hovering = false;
  bool _tooltipVisible = false;
  Timer? _hoverHideTimer;
  late final TextStyle _style;
  late Duration _hoverHideDelay;
  late final AnimationController _fadeController;
  late final Animation<double> _opacity;
  final GlobalKey _tooltipKey = GlobalKey();
  Offset _followerOffset = Offset.zero;
  bool _isDisposing = false;

  static const double _viewportMargin = 8.0;
  static const double _offsetEpsilon = 0.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final base = widget.textStyle ?? const TextStyle();
    _style =
        widget.theme.acronymStyle ??
        base.copyWith(
          decoration: widget.theme.underline
              ? TextDecoration.underline
              : TextDecoration.none,
          decorationStyle: widget.theme.decorationStyle,
          decorationThickness: widget.theme.decorationThickness,
          fontWeight: FontWeight.w600,
        );
    _hoverHideDelay =
        widget.theme.hoverHideDelay ?? widget.theme.hoverShowDelay;
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.theme.tooltipFadeDuration,
      value: 0,
    );
    _opacity = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _isDisposing = true;
    _hoverHideTimer?.cancel();
    _hide(immediate: true, announce: false);
    _focusNode.dispose();
    _fadeController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AcronymInline oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hoverHideDelay =
        widget.theme.hoverHideDelay ?? widget.theme.hoverShowDelay;
    if (oldWidget.theme.tooltipFadeDuration !=
        widget.theme.tooltipFadeDuration) {
      _fadeController.duration = widget.theme.tooltipFadeDuration;
    }
    if (_tooltipVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tooltipVisible) {
          _updateTooltipPosition();
        }
      });
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (_tooltipVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tooltipVisible) {
          _updateTooltipPosition();
        }
      });
    }
  }

  Offset _baseFollowerOffset(Size targetSize, TextDirection direction) {
    final horizontalAdjustment = direction == TextDirection.rtl
        ? -widget.theme.cardWidth + targetSize.width
        : 0.0;
    return Offset(
      horizontalAdjustment + widget.theme.tooltipOffset.dx,
      targetSize.height + widget.theme.tooltipOffset.dy,
    );
  }

  void _setFollowerOffset(Offset next) {
    if ((_followerOffset - next).distance < _offsetEpsilon) return;
    _followerOffset = next;
    if (_isDisposing) return;
    _entry?.markNeedsBuild();
  }

  void _toggle() {
    if (_tooltipVisible) {
      _hide();
    } else {
      _show();
    }
  }

  void _show() {
    if (_tooltipVisible) return;
    final overlay = Overlay.of(context, rootOverlay: true);
    _hoverHideTimer?.cancel();

    final renderBox = context.findRenderObject() as RenderBox?;
    final targetSize = renderBox?.size ?? Size.zero;
    final direction = Directionality.of(context);
    final strings = DashronymLocalizations.of(context);
    _setFollowerOffset(_baseFollowerOffset(targetSize, direction));

    _entry = OverlayEntry(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _tooltipVisible) {
            _updateTooltipPosition();
          }
        });
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hide,
                onSecondaryTap: _hide,
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: _followerOffset,
              child: FadeTransition(
                opacity: _opacity,
                child: DashronymTooltipCard(
                  key: _tooltipKey,
                  acronym: widget.acronym,
                  description: widget.description,
                  theme: widget.theme,
                  onClose: () => _hide(),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
    setState(() {
      _tooltipVisible = true;
    });
    _fadeController.forward(from: 0);

    SemanticsService.announce(
      strings.announceTooltipShown(widget.acronym),
      direction,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _tooltipVisible) {
        _updateTooltipPosition();
      }
    });
  }

  void _hide({bool immediate = false, bool announce = true}) {
    _hoverHideTimer?.cancel();
    if (_entry == null) {
      if (_tooltipVisible && mounted && !_isDisposing) {
        setState(() {
          _tooltipVisible = false;
          _hovering = false;
        });
      } else {
        _tooltipVisible = false;
        _hovering = false;
      }
      return;
    }

    void completeRemoval() {
      _entry?.remove();
      _entry = null;
      if (!mounted || _isDisposing) {
        _hovering = false;
        return;
      }
      setState(() {
        _hovering = false;
      });
      if (announce && !_isDisposing) {
        final strings = DashronymLocalizations.of(context);
        SemanticsService.announce(
          strings.announceTooltipHidden(widget.acronym),
          Directionality.of(context),
        );
      }
    }

    if (mounted && !_isDisposing && _tooltipVisible) {
      setState(() {
        _tooltipVisible = false;
      });
    } else {
      _tooltipVisible = false;
    }

    if (immediate) {
      _fadeController.stop();
      _fadeController.value = 0;
      completeRemoval();
      return;
    }

    _fadeController.reverse().whenComplete(completeRemoval);
  }

  void _updateTooltipPosition() {
    if (!_tooltipVisible) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    final overlayRenderObject = overlay.context.findRenderObject();
    final targetRenderObject = context.findRenderObject();
    final tooltipContext = _tooltipKey.currentContext;
    final tooltipRenderObject = tooltipContext?.findRenderObject();

    if (overlayRenderObject is! RenderBox || targetRenderObject is! RenderBox) {
      return;
    }

    if (tooltipRenderObject is! RenderBox) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tooltipVisible) {
          _updateTooltipPosition();
        }
      });
      return;
    }

    final overlayBox = overlayRenderObject;
    final targetBox = targetRenderObject;
    final tooltipBox = tooltipRenderObject;

    final overlaySize = overlayBox.size;
    final anchorTopLeft = targetBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final anchorSize = targetBox.size;
    final direction = Directionality.of(context);
    final mediaQuery = MediaQuery.maybeOf(context);

    final padding = mediaQuery?.padding ?? EdgeInsets.zero;
    final keyboardInset = mediaQuery != null
        ? math.max(mediaQuery.viewInsets.bottom, 0.0)
        : 0.0;

    final baseOffset = _baseFollowerOffset(anchorSize, direction);
    final cardSize = tooltipBox.size;

    final availableWidth = overlaySize.width - padding.left - padding.right;
    double horizontalMargin = _viewportMargin;
    final double horizontalMarginTotal = horizontalMargin * 2;
    if (cardSize.width + horizontalMarginTotal > availableWidth) {
      horizontalMargin = math.max(0.0, (availableWidth - cardSize.width) / 2.0);
    }

    final minLeft = padding.left + horizontalMargin;
    final maxLeft =
        overlaySize.width - padding.right - horizontalMargin - cardSize.width;

    final availableHeight =
        overlaySize.height - padding.top - padding.bottom - keyboardInset;
    double verticalMargin = _viewportMargin;
    final double verticalMarginTotal = verticalMargin * 2;
    if (cardSize.height + verticalMarginTotal > availableHeight) {
      verticalMargin = math.max(0.0, (availableHeight - cardSize.height) / 2.0);
    }

    final safeTop = padding.top + verticalMargin;
    final safeBottomLimit =
        overlaySize.height - padding.bottom - keyboardInset - verticalMargin;

    double left = anchorTopLeft.dx + baseOffset.dx;
    if (minLeft <= maxLeft) {
      left = left.clamp(minLeft, maxLeft);
    } else {
      left = minLeft;
    }

    final double desiredBelow = anchorTopLeft.dy + baseOffset.dy;
    double top = desiredBelow;
    final bool fitsBelow = desiredBelow + cardSize.height <= safeBottomLimit;
    final double desiredAbove =
        anchorTopLeft.dy - cardSize.height - widget.theme.tooltipOffset.dy;
    final bool fitsAbove = desiredAbove >= safeTop;

    if (!fitsBelow && fitsAbove) {
      top = desiredAbove;
    } else {
      top = math.min(desiredBelow, safeBottomLimit - cardSize.height);
      top = math.max(top, safeTop);
    }

    final newOffset = Offset(left - anchorTopLeft.dx, top - anchorTopLeft.dy);

    _setFollowerOffset(newOffset);
  }

  @override
  Widget build(BuildContext context) {
    final strings = DashronymLocalizations.of(context);
    final textWidget = Text(widget.acronym, style: _style);

    Widget result = CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          onEnter: widget.theme.enableHover
              ? (_) {
                  _hovering = true;
                  _hoverHideTimer?.cancel();
                  Future.delayed(widget.theme.hoverShowDelay, () {
                    if (mounted && _hovering) _show();
                  });
                }
              : null,
          onExit: widget.theme.enableHover
              ? (_) {
                  _hovering = false;
                  _hoverHideTimer?.cancel();
                  _hoverHideTimer = Timer(_hoverHideDelay, () {
                    if (mounted && !_hovering && !_focusNode.hasFocus) {
                      _hide();
                    }
                  });
                }
              : null,
          cursor: SystemMouseCursors.click,
          child: textWidget,
        ),
      ),
    );

    result = FocusableActionDetector(
      focusNode: _focusNode,
      onFocusChange: (focused) {
        if (focused) {
          _show();
        } else {
          _hide();
        }
      },
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<Intent>(
          onInvoke: (_) {
            _toggle();
            return null;
          },
        ),
        DismissIntent: CallbackAction<Intent>(
          onInvoke: (_) {
            _hide();
            return null;
          },
        ),
      },
      child: result,
    );

    return Semantics(
      button: true,
      label: widget.acronym,
      hint: _tooltipVisible
          ? strings.semanticsHintHide(widget.acronym)
          : strings.semanticsHintShow(widget.acronym),
      value: _tooltipVisible ? widget.description : null,
      onTap: _toggle,
      child: result,
    );
  }
}
