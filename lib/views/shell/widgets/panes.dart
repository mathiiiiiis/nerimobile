import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/shell/destinations.dart';

class ListPane extends StatelessWidget {
  const ListPane({super.key, required this.branch});

  final NeriBranch branch;

  @override
  Widget build(BuildContext context) => switch (branch) {
    NeriBranch.dashboard => const PlaceholderPane(label: 'Inbox'),
    NeriBranch.servers => const PlaceholderPane(label: 'Channels'),
    NeriBranch.explore => const PlaceholderPane(label: 'Explore sections'),
  };
}

class PlaceholderPane extends StatelessWidget {
  const PlaceholderPane({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Padding(
      padding: EdgeInsets.all(sizing.space(NeriSpacingRole.lg)),
      child: Container(
        decoration: BoxDecoration(
          color: colors[NeriToken.pane],
          borderRadius: sizing.rounded(NeriRadiusRole.md),
          border: Border.all(
            color: colors[NeriToken.border],
            width: sizing.dimen(NeriDimen.borderWidth),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: context.neriText[NeriTextRole.bodyLarge].copyWith(
              color: colors[NeriToken.textTertiary],
            ),
          ),
        ),
      ),
    );
  }
}

void showProfileMenu(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.neri[NeriToken.pane],
    builder: (context) => const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: PlaceholderPane(label: 'Profile menu'),
      ),
    ),
  );
}
