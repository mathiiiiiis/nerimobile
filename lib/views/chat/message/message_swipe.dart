import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';

const _replyAt = 0.15;
const _editAt = 0.35;
const _overdragResistance = 0.25;
const _settle = Duration(milliseconds: 200);

class MessageSwipe extends StatefulWidget {
  const MessageSwipe({
    super.key,
    required this.canReply,
    required this.onReply,
    required this.canEdit,
    required this.onEdit,
    required this.child,
  });

  final bool Function() canReply;
  final VoidCallback onReply;
  final bool Function() canEdit;
  final VoidCallback onEdit;
  final Widget child;

  @override
  State<MessageSwipe> createState() => _MessageSwipeState();
}

class _MessageSwipeState extends State<MessageSwipe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _settleController;

  double _width = 0;
  double _drag = 0;
  double _offset = 0;
  double _settleFrom = 0;
  bool _active = false;
  bool _editable = false;
  _SwipeAction _action = _SwipeAction.none;

  double get _curve => Curves.easeOut.transform(_settleController.value);
  double get _threshold => _width * _replyAt;

  _SwipeAction get _actionForDrag {
    if (_editable && _drag >= _width * _editAt) return _SwipeAction.edit;
    if (_drag >= _threshold) return _SwipeAction.reply;
    return _SwipeAction.none;
  }

  @override
  void initState() {
    super.initState();
    _settleController = AnimationController(vsync: this, duration: _settle)
      ..addListener(() => setState(() => _offset = _settleFrom * (1 - _curve)));
  }

  @override
  void dispose() {
    _settleController.dispose();
    super.dispose();
  }

  void _onStart(DragStartDetails details) {
    _active = widget.canReply();
    if (!_active) return;
    _editable = widget.canEdit();
    _action = _SwipeAction.none;
    _settleController.stop();
    _drag = -_offset;
  }

  void _onUpdate(DragUpdateDetails details) {
    if (!_active) return;

    final previous = _action;
    _drag = (_drag - details.delta.dx).clamp(0.0, _width);
    _action = _actionForDrag;
    if (_action.index > previous.index) HapticFeedback.lightImpact();

    final overdrag = (_drag - _threshold).clamp(0.0, double.infinity);
    setState(() => _offset = -(_drag - overdrag * (1 - _overdragResistance)));
  }

  void _onEnd(DragEndDetails details) {
    if (_active) {
      switch (_action) {
        case _SwipeAction.reply:
          widget.onReply();
        case _SwipeAction.edit:
          widget.onEdit();
        case _SwipeAction.none:
          break;
      }
    }
    _settleBack();
  }

  void _settleBack() {
    if (!_active) return;
    _active = false;
    _drag = 0;
    _settleFrom = _offset;
    _settleController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final progress = _threshold == 0
        ? 0.0
        : (-_offset / _threshold).clamp(0.0, 1.0);

    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        _LeftwardDragRecognizer:
            GestureRecognizerFactoryWithHandlers<_LeftwardDragRecognizer>(
              _LeftwardDragRecognizer.new,
              (recognizer) => recognizer
                ..gestureSettings = MediaQuery.maybeGestureSettingsOf(context)
                ..onStart = _onStart
                ..onUpdate = _onUpdate
                ..onEnd = _onEnd
                ..onCancel = _settleBack,
            ),
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          _width = constraints.maxWidth;

          return Stack(
            children: [
              if (progress > 0)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: sizing.space(NeriSpacingRole.lg),
                      ),
                      child: Opacity(
                        opacity: progress,
                        child: Transform.scale(
                          scale: 0.5 + progress / 2,
                          child: Icon(
                            _action == _SwipeAction.edit
                                ? Symbols.edit_rounded
                                : Symbols.reply_rounded,
                            size: sizing.dimen(NeriDimen.iconMd),
                            color: progress == 1
                                ? context.neri[NeriToken.primary]
                                : context.neri[NeriToken.textSecondary],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(_offset, 0),
                child: widget.child,
              ),
            ],
          );
        },
      ),
    );
  }
}

enum _SwipeAction { none, reply, edit }

class _LeftwardDragRecognizer extends HorizontalDragGestureRecognizer {
  double _dx = 0;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _dx = 0;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) _dx += event.delta.dx;
    super.handleEvent(event);
  }

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) => _dx < -computeHitSlop(pointerDeviceKind, gestureSettings);
}
