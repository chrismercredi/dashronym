import 'package:flutter/material.dart';

import 'theme.dart';

/// Inline acronym widget used inside a [WidgetSpan].
///
/// Opens a Material overlay that looks like a small [ListTile] card.
class AcronymInline extends StatefulWidget {
  const AcronymInline({
    super.key,
    required this.acronym,
    required this.description,
    required this.theme,
    required this.textStyle,
  });

  final String acronym;
  final String description;
  final DashronymTheme theme;
  final TextStyle? textStyle;

  @override
  State<AcronymInline> createState() => _AcronymInlineState();
}

class _AcronymInlineState extends State<AcronymInline> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  bool _hovering = false;
  late final TextStyle _style;

  @override
  void initState() {
    super.initState();
    final base = widget.textStyle ?? const TextStyle();
    _style = widget.theme.acronymStyle ??
        base.copyWith(
          decoration:
              widget.theme.underline ? TextDecoration.underline : TextDecoration.none,
          decorationStyle: widget.theme.decorationStyle,
          decorationThickness: widget.theme.decorationThickness,
          fontWeight: FontWeight.w600,
        );
  }

  void _show() {
    if (_entry != null) return;
    final overlay = Overlay.of(context, rootOverlay: true);

    final renderBox = context.findRenderObject() as RenderBox?;
    final targetSize = renderBox?.size ?? Size.zero;

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
              offset: Offset(0, targetSize.height + 6),
              child: Material(
                elevation: widget.theme.cardElevation,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widget.theme.cardWidth),
                  child: Padding(
                    padding: widget.theme.cardPadding,
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(
                        widget.acronym,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(widget.description),
                      trailing: IconButton(
                        tooltip: 'Close',
                        icon: const Icon(Icons.close),
                        onPressed: _hide,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minLeadingWidth: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
    _hovering = false;
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = Text(
      widget.acronym,
      style: _style,
      semanticsLabel: '${widget.acronym}: ${widget.description}',
    );

    Widget result = CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _show,
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
          child: child,
        ),
      ),
    );

    result = FocusableActionDetector(
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<Intent>(
          onInvoke: (_) {
            _show();
            return null;
          },
        ),
      },
      child: result,
    );

    return result;
  }
}
