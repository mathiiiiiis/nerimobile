import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CachedSvgLoader extends SvgLoader<Uint8List> {
  const CachedSvgLoader(this.url);

  final String url;

  @override
  Future<Uint8List?> prepareMessage(BuildContext? context) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    return file.readAsBytes();
  }

  @override
  String provideSvg(Uint8List? message) =>
      utf8.decode(message!, allowMalformed: true);

  //uses by flutter_svgs picture cache
  @override
  int get hashCode => url.hashCode;

  @override
  bool operator ==(Object other) =>
      other is CachedSvgLoader && other.url == url;
}
