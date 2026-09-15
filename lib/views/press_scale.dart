import 'package:flutter/widgets.dart';

const _pressedScale = 0.9;
const _pressDuration = Duration(milliseconds: 150);

class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child});

  final Widget child;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? _pressedScale : 1,
        duration: _pressDuration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
