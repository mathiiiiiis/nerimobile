import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';

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
