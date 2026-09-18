import 'package:flutter/gestures.dart';

typedef OpenLink = void Function(String url, {required bool masked});

class LinkTapController {
  LinkTapController(this.open);

  final OpenLink open;
  final _recognizers = <String, TapGestureRecognizer>{};

  GestureRecognizer? recognizer(String url, {bool masked = false}) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAuthority) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;

    return _recognizers['$masked $url'] ??= TapGestureRecognizer()
      ..onTap = () => open(url, masked: masked);
  }

  void reset() {
    for (final recognizer in _recognizers.values) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }
}
