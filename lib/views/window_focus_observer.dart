import 'package:flutter/material.dart';
import 'package:nerimobile/stores/mouse_store.dart';
import 'package:nerimobile/stores/window_focus_store.dart';

class FocusObserver extends StatefulWidget {
  final Widget child;
  const FocusObserver({required this.child, super.key});

  @override
  State<FocusObserver> createState() => _FocusObserverState();
}

class _FocusObserverState extends State<FocusObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration(milliseconds: 500), () {
      if (!mounted) return;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (lastClickPosition.value == Offset.zero) return;
    isWindowFocused.value = state == AppLifecycleState.resumed;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
