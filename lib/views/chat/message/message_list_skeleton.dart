import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/skeleton.dart';

const _groups = 5;
const _nameWidth = 96.0;
const _nameHeight = 12.0;
const _lineHeight = 12.0;
const _lines = [
  [216.0, 148.0],
  [176.0],
  [244.0, 196.0, 92.0],
  [132.0],
  [208.0, 118.0],
];

class MessageListSkeleton extends StatelessWidget {
  const MessageListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final avatar = sizing.dimen(NeriDimen.controlSize);

    return SkeletonScope(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        reverse: true,
        padding: EdgeInsets.only(
          bottom: sizing.space(NeriSpacingRole.xl),
          top:
              sizing.dimen(NeriDimen.channelHeaderHeight) +
              sizing.space(NeriSpacingRole.md) * 2,
        ),
        itemCount: _groups,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sizing.space(NeriSpacingRole.md),
            vertical: sizing.space(NeriSpacingRole.sm),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: sizing.space(NeriSpacingRole.md),
            children: [
              SkeletonBlock(
                width: avatar,
                height: avatar,
                shape: NeriRadiusRole.full,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: sizing.space(NeriSpacingRole.sm),
                  children: [
                    const SkeletonBlock(width: _nameWidth, height: _nameHeight),
                    for (final width in _lines[index % _lines.length])
                      SkeletonBlock(width: width, height: _lineHeight),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
