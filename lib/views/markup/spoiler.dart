import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SpoilerController {
  SpoilerController({required this.onChanged});

  final VoidCallback onChanged;
  final Set<int> _revealed = {};
  final Map<int, TapGestureRecognizer> _recognizers = {};
  int? _pressed;

  bool isRevealed(int index) => _revealed.contains(index);

  bool isPressed(int index) => _pressed == index;

  GestureRecognizer recognizer(int index) {
    return _recognizers.putIfAbsent(index, () {
      final recognizer = TapGestureRecognizer();
      recognizer.onTapDown = (_) => press(index, true);
      recognizer.onTapCancel = () => press(index, false);
      recognizer.onTapUp = (_) => press(index, false);
      recognizer.onTap = () => reveal(index);
      return recognizer;
    });
  }

  void reveal(int index) {
    if (_revealed.add(index)) onChanged();
  }

  void press(int index, bool pressed) {
    final next = pressed ? index : null;
    if (_pressed == next) return;
    _pressed = next;
    onChanged();
  }

  void reset() {
    for (final recognizer in _recognizers.values) {
      recognizer.dispose();
    }
    _recognizers.clear();
    _revealed.clear();
    _pressed = null;
  }
}

//widget spans need a cover
class SpoilerCover extends StatelessWidget {
  const SpoilerCover({
    super.key,
    required this.color,
    required this.onTap,
    required this.onPressed,
    required this.child,
  });

  final Color color;
  final VoidCallback onTap;
  final ValueChanged<bool> onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => onPressed(true),
      onTapCancel: () => onPressed(false),
      onTapUp: (_) => onPressed(false),
      child: Stack(
        children: [
          Opacity(opacity: 0, child: child),
          Positioned.fill(child: ColoredBox(color: color)),
        ],
      ),
    );
  }
}
