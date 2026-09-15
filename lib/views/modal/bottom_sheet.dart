import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';

class SheetAction {
  const SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
}

Future<void> showActionSheet(
  BuildContext context, {
  required List<SheetAction> actions,
  Widget? header,
}) async {
  final colors = context.neri;
  final radius = Radius.circular(context.neriSize.radius(NeriRadiusRole.xl));

  final picked = await showModalBottomSheet<SheetAction>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: colors[NeriToken.pane],
    barrierColor: colors[NeriToken.scrim],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
    ),
    builder: (context) => _ActionSheet(header: header, actions: actions),
  );
  picked?.onTap();
}

class _ActionSheet extends StatelessWidget {
  const _ActionSheet({required this.actions, this.header});

  final List<SheetAction> actions;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: sizing.space(NeriSpacingRole.sm)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header case final header?)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  sizing.space(NeriSpacingRole.lg),
                  0,
                  sizing.space(NeriSpacingRole.lg),
                  sizing.space(NeriSpacingRole.sm),
                ),
                child: header,
              ),
            for (final action in actions) _ActionRow(action: action),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.action});

  final SheetAction action;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final color = action.destructive
        ? colors[NeriToken.alert]
        : colors[NeriToken.text];

    return InkWell(
      onTap: () => Navigator.of(context).pop(action),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sizing.space(NeriSpacingRole.lg),
          vertical: sizing.space(NeriSpacingRole.md),
        ),
        child: Row(
          spacing: sizing.space(NeriSpacingRole.lg),
          children: [
            Icon(
              action.icon,
              size: sizing.dimen(NeriDimen.iconSm),
              color: action.destructive
                  ? color
                  : colors[NeriToken.textSecondary],
            ),
            Expanded(
              child: Text(
                action.label,
                style: context.neriText[NeriTextRole.bodyLarge].copyWith(
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
