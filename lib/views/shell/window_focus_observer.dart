import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/stores/connection/connection_store.dart';

import 'package:nerimobile/stores/window/window_focus_store.dart';

class FocusObserver extends ConsumerStatefulWidget {
  final Widget child;
  const FocusObserver({required this.child, super.key});

  @override
  ConsumerState<FocusObserver> createState() => _FocusObserverState();
}

class _FocusObserverState extends ConsumerState<FocusObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;

    ref.read(windowFocusProvider.notifier).setFocused(resumed);
    if (resumed) ref.read(connectionProvider.notifier).resume();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
