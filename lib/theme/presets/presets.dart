import 'package:nerimobile/theme/core/theme_spec.dart';
import 'package:nerimobile/theme/presets/nerimobile.dart';
import 'package:nerimobile/theme/presets/nerimity_dark.dart';
import 'package:nerimobile/theme/presets/nerimity_classic.dart';

const defaultPresetId = 'nerimobile';

const builtInPresets = <String, ThemeSpec>{
  'nerimobile': nerimobilePreset,
  'nerimity-classic': nerimityClassicPreset,
  'nerimity-dark': nerimityDarkPreset,
};

ThemeSpec presetById(String? id) =>
    builtInPresets[id] ?? builtInPresets[defaultPresetId]!;
