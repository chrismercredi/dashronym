import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import 'localizations.dart';
import 'theme.dart';
import 'tooltip_card.dart';

/// Inline acronym widget used inside a [WidgetSpan].
///
/// Opens a Material overlay that looks like a small [ListTile] card and
/// supports keyboard, screen reader, and pointer interactions.
class AcronymInline extends StatefulWidget {
  const AcronymInline({
    super.key,
    required this.acronym,
    required this.description,
    required this.theme,
    required this.textStyle,
  });

  /// The acronym presented inline.
  final String acronym;

  /// The description rendered inside the tooltip card.
  final String description;

  /// Visual customization for the trigger and tooltip.
  final DashronymTheme theme;

  /// Text style inherited from the surrounding span.
  final TextStyle? textStyle;

  @override
  State<AcronymInline> createState() => _AcronymInlineState();
}

class _AcronymInlineState extends State<AcronymInline> {
  final LayerLink _link = LayerLink();
  final FocusNode _focusNode = FocusNode(debugLabel: 'DashronymInline');

  OverlayEntry? _entry;
  bool _hovering = false;
  bool _tooltipVisible = false;
  late final TextStyle _style;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _hide();
    _focusNode.dispose();
    super.dispose();
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

    final renderBox = context.findRenderObject() as RenderBox?;
    final targetSize = renderBox?.size ?? Size.zero;
    final direction = Directionality.of(context);
    final strings = DashronymLocalizations.of(context);

    final horizontalAdjustment = direction == TextDirection.rtl
        ? -widget.theme.cardWidth + targetSize.width
        : 0.0;
    final offset = Offset(
      horizontalAdjustment + widget.theme.tooltipOffset.dx,
      targetSize.height + widget.theme.tooltipOffset.dy,
    );

    _entry = OverlayEntry(
      builder: (context) {
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
              offset: offset,
              child: DashronymTooltipCard(
                acronym: widget.acronym,
                description: widget.description,
                theme: widget.theme,
                onClose: _hide,
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

    SemanticsService.announce(
      strings.announceTooltipShown(widget.acronym),
      direction,
    );
  }

  void _hide() {
    if (!_tooltipVisible) return;
    _entry?.remove();
    _entry = null;
    setState(() {
      _hovering = false;
      _tooltipVisible = false;
    });

    if (!mounted) return;

    final strings = DashronymLocalizations.of(context);
    SemanticsService.announce(
      strings.announceTooltipHidden(widget.acronym),
      Directionality.of(context),
    );
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
                  Future.delayed(widget.theme.hoverShowDelay, () {
                    if (mounted && _hovering) _show();
                  });
                }
              : null,
          onExit: widget.theme.enableHover
              ? (_) {
                  _hovering = false;
                }
              : null,
          cursor: SystemMouseCursors.click,
          child: Tooltip(
            message: strings.tooltipMessage(widget.acronym, widget.description),
            preferBelow: false,
            child: textWidget,
          ),
        ),
      ),
    );

    result = FocusableActionDetector(
      focusNode: _focusNode,
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
