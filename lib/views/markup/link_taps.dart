import 'package:flutter/gestures.dart';
import 'package:nerimobile/utils/url.dart';

class LinkTapController {
  final _recognizers = <String, TapGestureRecognizer>{};

  GestureRecognizer? recognizer(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAuthority) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;

    return _recognizers[url] ??= TapGestureRecognizer()
      ..onTap = () => openExternal(url);
  }

  void reset() {
    for (final recognizer in _recognizers.values) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }
}
