import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

const _visibleFor = Duration(milliseconds: 2500);
const _clipboardPreviewSdk = 33;

//andr13+ show own copied text preview
final Future<bool> _systemShowsCopies = Platform.isAndroid
    ? DeviceInfoPlugin().androidInfo.then(
        (info) => info.version.sdkInt >= _clipboardPreviewSdk,
      )
    : Future.value(false);

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

  Future<void> copy(String text, {required String label}) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (await _systemShowsCopies) return;

    show(label, icon: Symbols.content_copy_rounded);
  }
}
