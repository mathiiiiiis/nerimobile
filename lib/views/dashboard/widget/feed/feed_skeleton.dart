import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/skeleton/skeleton.dart';

const _heights = [136.0, 104.0, 152.0];

class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return SkeletonScope(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: sizing.space(NeriSpacingRole.md),
        children: [
          for (final height in _heights)
            SkeletonBlock(height: height, shape: NeriRadiusRole.lg),
        ],
      ),
    );
  }
}
