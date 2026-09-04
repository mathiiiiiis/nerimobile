import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
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

    return Center(
      child: Text(
        label,
        style: context.neriText[NeriTextRole.bodyLarge].copyWith(
          color: colors[NeriToken.textTertiary],
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
