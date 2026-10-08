import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/skeleton/skeleton.dart';

const _nameWidths = [96.0, 132.0, 72.0, 118.0, 88.0, 140.0, 104.0, 80.0];
const _categoryWidth = 64.0;
const _nameHeight = 14.0;
const _categoryHeight = 10.0;
const _categoryAt = {0, 4};

class ChannelListSkeleton extends StatelessWidget {
  const ChannelListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final icon = sizing.dimen(NeriDimen.emojiSm);

    return SkeletonScope(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _nameWidths.length,
        itemBuilder: (context, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_categoryAt.contains(index))
              Padding(
                padding: EdgeInsets.fromLTRB(
                  sizing.space(NeriSpacingRole.md),
                  sizing.space(NeriSpacingRole.md),
                  sizing.space(NeriSpacingRole.md),
                  sizing.space(NeriSpacingRole.xs),
                ),
                child: const SkeletonBlock(
                  width: _categoryWidth,
                  height: _categoryHeight,
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sizing.space(NeriSpacingRole.md),
                vertical: sizing.space(NeriSpacingRole.xs),
              ),
              child: Row(
                spacing: sizing.space(NeriSpacingRole.xs),
                children: [
                  SkeletonBlock(width: icon, height: icon),
                  SkeletonBlock(width: _nameWidths[index], height: _nameHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
