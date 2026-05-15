import 'package:flutter/material.dart';
import 'package:nerimobile/stores/mouse_store.dart';
import 'package:nerimobile/stores/window_focus_store.dart';

class MouseObserver extends StatelessWidget {
  final Widget child;
  const MouseObserver({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        lastClickPosition.value = event.position;
        isWindowFocused.value = true;
      },
      child: child,
    );
  }
}
