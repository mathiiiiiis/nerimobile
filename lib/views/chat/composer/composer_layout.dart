import 'package:flutter/material.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';

const composerFieldHeight = 48.0;

double composerStripInset(BuildContext context) =>
    (composerFieldHeight - context.neriSize.dimen(NeriDimen.iconMd)) / 2;
