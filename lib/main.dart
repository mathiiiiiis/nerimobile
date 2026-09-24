import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:media_kit/media_kit.dart';
import 'package:timezone/data/latest_all.dart' as timezones;

import 'package:nerimobile/app.dart';

const _svgCacheSize = 2500;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  svg.cache.maximumSize = _svgCacheSize;
  MediaKit.ensureInitialized();
  timezones.initializeTimeZones();
  runApp(const ProviderScope(child: MainApp()));
}
