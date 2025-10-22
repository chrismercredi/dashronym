/// Dashronym inline trigger widgets and tooltip surface integration.
///
/// This file defines:
///
/// * [AcronymInline] — an inline, accessible trigger that shows a tooltip for a term.
/// * [AcronymTooltipDetails] — the metadata passed to a custom [DashronymTooltipBuilder].
/// * [DashronymTooltipBuilder] — a typedef for building a custom tooltip widget.
///
/// ### Sizing behavior at a glance
/// The tooltip body is sized inside [DashronymTooltipCard], which caps its width
/// to the smallest finite viewport or theme limit (with
/// [DashronymTheme.tooltipMaxWidth] taking precedence when provided) and lets
/// content wrap naturally at word boundaries. The inline widget intentionally
/// **does not** impose a maximum width—it only enforces an optional minimum via
/// [DashronymTheme.tooltipMinWidth] to avoid double capping.
///
/// ### Example
/// ```dart
/// Wrap(
///   crossAxisAlignment: WrapCrossAlignment.center,
///   spacing: 4,
///   children: [
///     const Text('Install the'),
///     AcronymInline(
///       acronym: 'SDK',
///       description: 'Software Development Kit',
///       theme: myDashronymTheme,
///       textStyle: Theme.of(context).textTheme.bodyMedium,
///     ),
///     const Text('before continuing.'),
///   ],
/// );
/// ```
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import 'localizations.dart';
import 'theme.dart';
import 'tooltip_card.dart';
import 'tooltip_positioner.dart';
import 'tooltip_constraints.dart';

/// Signature used to build a custom tooltip widget for [AcronymInline].
/// Signature for building a custom tooltip widget used by [AcronymInline].
///
/// The function receives the current [BuildContext] and an [AcronymTooltipDetails]
/// object describing the selected term. Return any widget you want to display as the
/// tooltip body (e.g. a custom card, sheet, etc.).
///
/// ### Example
/// ```dart
/// AcronymInline(
///   acronym: 'CI',
///   description: 'Continuous Integration',
///   theme: theme,
///   textStyle: Theme.of(context).textTheme.bodyMedium,
///   tooltipBuilder: (context, details) {
///     return DashronymTooltipCard(
///       acronym: details.acronym,
///       description: details.description,
///       theme: details.theme.copyWith(cardElevation: 8),
///       onClose: details.hideTooltip,
///     );
///   },
/// );
/// ```
typedef DashronymTooltipBuilder =
    Widget Function(BuildContext context, AcronymTooltipDetails details);

/// Data surfaced to [DashronymTooltipBuilder] implementations.
class AcronymTooltipDetails {
  /// Creates tooltip metadata provided to custom tooltip builders.
  const AcronymTooltipDetails({
    required this.acronym,
    required this.description,
    required this.theme,
    required this.hideTooltip,
  });

  /// The acronym shown by the inline trigger.
  final String acronym;

  /// The long-form description associated with [acronym].
  final String description;

  /// The effective theme driving tooltip styling.
  final DashronymTheme theme;

  /// Callback that hides the tooltip overlay.
  final VoidCallback hideTooltip;
}

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
/// // Defaults
/// Text('Tap (SDK) to learn more.')
///     .dashronyms(registry: registry, config: config);
///
/// // Custom tooltip content
/// Text('(API) tooltip with branded content.')
///     .dashronyms(
///       registry: registry,
///       config: config,
///       tooltipBuilder: (context, details) {
///         return Card(
///           child: ListTile(
///             title: Text(details.acronym),
///             subtitle: Text(details.description),
///             trailing: IconButton(
///               icon: const Icon(Icons.close),
///               onPressed: details.hideTooltip,
///             ),
///           ),
///         );
///       },
///     );
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
    this.tooltipBuilder,
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

  /// Allows callers to provide a custom tooltip instead of [DashronymTooltipCard].
  final DashronymTooltipBuilder? tooltipBuilder;

  /// Creates the backing state object.
  ///
  /// You typically do not need to call this.
  @override
  State<AcronymInline> createState() => _AcronymInlineState();
}

class _AcronymInlineState extends State<AcronymInline>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static _AcronymInlineState? _activeTooltip;

  final LayerLink _link = LayerLink();
  final FocusNode _focusNode = FocusNode(debugLabel: 'DashronymInline');

  OverlayEntry? _entry;
  bool _hovering = false;
  bool _tooltipVisible = false;
  Timer? _hoverHideTimer;
  Timer? _announceDebounce;
  ScrollPosition? _scrollPosition;
  late final TextStyle _style;
  late Duration _hoverHideDelay;
  late final AnimationController _fadeController;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  final GlobalKey _tooltipKey = GlobalKey();
  Offset _followerOffset = Offset.zero;
  bool _isDisposing = false;
  Orientation? _lastOrientation;

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
    _configureAnimations(widget.theme);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposing) return;
      _attachScrollListener();
    });
  }

  @override
  void dispose() {
    _isDisposing = true;
    _hoverHideTimer?.cancel();
    _announceDebounce?.cancel();
    _scrollPosition?.removeListener(_handleScrollDismiss);
    _scrollPosition = null;
    _hide(immediate: true, announce: false);
    _focusNode.dispose();
    _fadeController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @visibleForTesting
  void debugRemoveEntry() {
    _entry?.remove();
    _entry = null;
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
    _configureAnimations(widget.theme);
    if (_tooltipVisible) {
      _postFrameIfVisible(_updateTooltipPosition);
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final orientation = _windowOrientation();
    if (_tooltipVisible) {
      _hide(immediate: true);
    }
    if (orientation != null) {
      _lastOrientation = orientation;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orientation = MediaQuery.maybeOf(context)?.orientation;
    if (orientation != null && _lastOrientation != orientation) {
      if (_lastOrientation != null) {
        _hide(immediate: true); // coverage:ignore-line
      }
      _lastOrientation = orientation;
    }
    _attachScrollListener();
  }

  Orientation? _windowOrientation() {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return null;
    final view = views.first;
    final logicalSize = view.physicalSize / view.devicePixelRatio;
    if (logicalSize.width == 0 || logicalSize.height == 0) return null;
    return logicalSize.width > logicalSize.height
        ? Orientation.landscape
        : Orientation.portrait;
  }

  void _attachScrollListener() {
    if (_isDisposing) return;
    final scrollableState = Scrollable.maybeOf(context);
    final newPosition = scrollableState?.position;
    if (identical(_scrollPosition, newPosition)) return;
    _scrollPosition?.removeListener(_handleScrollDismiss);
    _scrollPosition = newPosition;
    _scrollPosition?.addListener(_handleScrollDismiss);
  }

  void _setFollowerOffset(Offset next) {
    if ((_followerOffset - next).distance < _offsetEpsilon) return;
    _followerOffset = next;
    if (_isDisposing) return;
    _entry?.markNeedsBuild();
  }

  RenderBox? _boxOf(BuildContext? context, {bool requireSize = true}) {
    if (!mounted || context == null) return null;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return null;
    if (requireSize && renderObject.hasSize && renderObject.size.isEmpty) {
      return null;
    }
    return renderObject;
  }

  void _postFrameIfVisible(void Function() fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_tooltipVisible || _isDisposing) return;
      fn();
    });
  }

  void _handleScrollDismiss() {
    if (!_tooltipVisible || _isDisposing) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposing) return;
      _hide();
    });
  }

  void _configureAnimations(DashronymTheme theme) {
    _opacity = CurvedAnimation(
      parent: _fadeController,
      curve: theme.tooltipFadeInCurve,
      reverseCurve: theme.tooltipFadeOutCurve,
    );
    _scale =
        Tween<double>(
          begin: theme.tooltipScaleBegin,
          end: theme.tooltipScaleEnd,
        ).animate(
          CurvedAnimation(
            parent: _fadeController,
            curve: theme.tooltipScaleInCurve,
            reverseCurve: theme.tooltipScaleOutCurve,
          ),
        );
  }

  void _announce(String message) {
    if (_isDisposing) return;
    _announceDebounce?.cancel();
    _announceDebounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted || _isDisposing) return;
      SemanticsService.announce(message, Directionality.of(context));
    });
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

    final renderBox = _boxOf(context);
    final targetSize = renderBox?.size ?? Size.zero;
    final direction = Directionality.of(context);
    final strings = DashronymLocalizations.of(context);
    _setFollowerOffset(
      AcronymTooltipPositioner.baseFollowerOffset(
        anchorSize: targetSize,
        theme: widget.theme,
        direction: direction,
      ),
    );

    _entry = OverlayEntry(
      builder: (context) {
        _postFrameIfVisible(_updateTooltipPosition);
        final tooltipDetails = AcronymTooltipDetails(
          acronym: widget.acronym,
          description: widget.description,
          theme: widget.theme,
          hideTooltip: () => _hide(),
        );
        final builtTooltip =
            widget.tooltipBuilder?.call(context, tooltipDetails) ??
            DashronymTooltipCard(
              acronym: widget.acronym,
              description: widget.description,
              theme: widget.theme,
              onClose: () => _hide(),
            );
        final keyedTooltip = KeyedSubtree(
          key: _tooltipKey,
          child: _TooltipViewportClamp(
            theme: widget.theme,
            child: builtTooltip,
          ),
        );
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
                child: ScaleTransition(scale: _scale, child: keyedTooltip),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
    if (_activeTooltip != this) {
      _activeTooltip?._hide(immediate: true, announce: false);
    }
    _activeTooltip = this;
    setState(() {
      _tooltipVisible = true;
    });
    _fadeController.forward(from: 0);

    _announce(strings.announceTooltipShown(widget.acronym));

    _postFrameIfVisible(_updateTooltipPosition);
  }

  void _hide({bool immediate = false, bool announce = true}) {
    _hoverHideTimer?.cancel();
    if (_entry == null) {
      final shouldNotify = _tooltipVisible && mounted && !_isDisposing;
      _tooltipVisible = false;
      _hovering = false;
      if (shouldNotify) {
        setState(() {}); // coverage:ignore-line
      }
      return;
    }

    void completeRemoval() {
      _entry?.remove();
      _entry = null;
      if (identical(_activeTooltip, this)) {
        _activeTooltip = null;
      }
      if (!mounted || _isDisposing) {
        _hovering = false;
        return;
      }
      setState(() {
        _hovering = false;
      });
      if (announce && !_isDisposing) {
        final strings = DashronymLocalizations.of(context);
        _announce(strings.announceTooltipHidden(widget.acronym));
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
    final overlayBox = _boxOf(overlay.context);
    final targetBox = _boxOf(context);
    final tooltipBox = _boxOf(_tooltipKey.currentContext, requireSize: false);

    if (overlayBox == null || targetBox == null || tooltipBox == null) {
      if (tooltipBox == null) {
        _postFrameIfVisible(_updateTooltipPosition); // coverage:ignore-line
      }
      return;
    }

    final overlaySize = overlayBox.size;
    final anchorTopLeft = targetBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final anchorSize = targetBox.size;
    final direction = Directionality.of(context);
    final mediaQuery = MediaQuery.maybeOf(context);

    final padding = mediaQuery?.padding ?? EdgeInsets.zero;
    final rawKeyboardInset = mediaQuery?.viewInsets.bottom ?? 0.0;
    final keyboardInset = rawKeyboardInset < 0.0 ? 0.0 : rawKeyboardInset;

    final newOffset = AcronymTooltipPositioner.resolveFollowerOffset(
      overlaySize: overlaySize,
      anchorTopLeft: anchorTopLeft,
      anchorSize: anchorSize,
      tooltipSize: tooltipBox.size,
      theme: widget.theme,
      padding: padding,
      keyboardInset: keyboardInset,
      direction: direction,
      viewportMargin: _viewportMargin,
    );

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

class _TooltipViewportClamp extends StatelessWidget {
  const _TooltipViewportClamp({required this.theme, required this.child});

  final DashronymTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    return LayoutBuilder(
      builder: (context, parentConstraints) {
        final mqForBuilder = MediaQuery.maybeOf(context) ?? mediaQuery;
        final resolvedConstraints = TooltipConstraintsResolver.resolve(
          constraints: parentConstraints,
          mediaQuery: mqForBuilder,
          theme: theme,
        );
        return ConstrainedBox(constraints: resolvedConstraints, child: child);
      },
    );
  }
}
