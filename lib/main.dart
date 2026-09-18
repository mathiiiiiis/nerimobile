import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:timezone/data/latest_all.dart' as timezones;

import 'package:nerimobile/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  timezones.initializeTimeZones();
  runApp(const ProviderScope(child: MainApp()));
}
