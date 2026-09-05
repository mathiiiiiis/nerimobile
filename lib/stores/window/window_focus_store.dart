import 'package:flutter_riverpod/flutter_riverpod.dart';

final windowFocusProvider = NotifierProvider<WindowFocusNotifier, bool>(
  WindowFocusNotifier.new,
);

class WindowFocusNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setFocused(bool focused) => state = focused;
}
