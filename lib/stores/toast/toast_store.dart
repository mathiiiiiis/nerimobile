import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _visibleFor = Duration(milliseconds: 2500);

class Toast {
  const Toast({
    required this.id,
    required this.message,
    this.icon,
    this.alert = false,
  });

  final int id;
  final String message;
  final IconData? icon;
  final bool alert;
}

final toastProvider = NotifierProvider<ToastNotifier, Toast?>(
  ToastNotifier.new,
);

class ToastNotifier extends Notifier<Toast?> {
  Timer? _hide;
  var _nextId = 0;

  @override
  Toast? build() {
    ref.onDispose(() => _hide?.cancel());
    return null;
  }

  //newer replaces current, no queueing
  void show(String message, {IconData? icon, bool alert = false}) {
    _hide?.cancel();
    state = Toast(id: _nextId++, message: message, icon: icon, alert: alert);
    _hide = Timer(_visibleFor, () => state = null);
  }
}
