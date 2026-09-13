import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/skeleton.dart';

const _rows = 7;
const _nameWidths = [122.0, 86.0, 148.0, 104.0, 132.0, 94.0, 116.0];
const _lineWidths = [64.0, 92.0, 58.0, 76.0, 50.0, 84.0, 68.0];
const _nameHeight = 14.0;
const _lineHeight = 10.0;

class DmListSkeleton extends StatelessWidget {
  const DmListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final size = sizing.dimen(NeriDimen.avatarMd);

    return SkeletonScope(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _rows,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sizing.space(NeriSpacingRole.md),
            vertical: sizing.space(NeriSpacingRole.xs),
          ),
          child: Row(
            spacing: sizing.space(NeriSpacingRole.md),
            children: [
              SkeletonBlock(
                width: size,
                height: size,
                shape: NeriRadiusRole.full,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: sizing.space(NeriSpacingRole.xs),
                children: [
                  SkeletonBlock(
                    width: _nameWidths[index % _nameWidths.length],
                    height: _nameHeight,
                  ),
                  SkeletonBlock(
                    width: _lineWidths[index % _lineWidths.length],
                    height: _lineHeight,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
