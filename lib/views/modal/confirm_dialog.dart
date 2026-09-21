import 'package:flutter/material.dart';

import 'package:nerimobile/theme/colors/derive.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/press_scale.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? message,
  String cancelLabel = 'Cancel', //TODO: add l10n
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: context.neri[NeriToken.scrim],
    builder: (context) => _ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );
  return confirmed ?? false;
}

Future<void> showNoticeDialog(
  BuildContext context, {
  required String title,
  String? message,
  String okLabel = 'OK', //TODO: add l10n
}) => showDialog<void>(
  context: context,
  barrierColor: context.neri[NeriToken.scrim],
  builder: (context) => _ConfirmDialog(
    title: title,
    message: message,
    confirmLabel: okLabel,
    cancelLabel: null,
    destructive: false,
  ),
);

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.destructive,
    this.message,
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final String? cancelLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final text = context.neriText;
    final accent = destructive
        ? colors[NeriToken.alert]
        : colors[NeriToken.primary];
    final buttonShape = RoundedRectangleBorder(
      borderRadius: sizing.rounded(NeriRadiusRole.md),
    );

    return Dialog(
      backgroundColor: colors[NeriToken.pane],
      shape: RoundedRectangleBorder(
        borderRadius: sizing.rounded(NeriRadiusRole.xl),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: sizing.dimen(NeriDimen.dialogWidth),
        ),
        child: Padding(
          padding: EdgeInsets.all(sizing.space(NeriSpacingRole.xl)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: sizing.space(NeriSpacingRole.sm),
            children: [
              Text(
                title,
                style: text[NeriTextRole.headlineSmall].copyWith(
                  color: colors[NeriToken.text],
                ),
              ),
              if (message case final message?)
                Text(
                  message,
                  style: text[NeriTextRole.bodyMedium].copyWith(
                    color: colors[NeriToken.textSecondary],
                  ),
                ),
              SizedBox(height: sizing.space(NeriSpacingRole.sm)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: sizing.space(NeriSpacingRole.sm),
                children: [
                  if (cancelLabel case final cancelLabel?)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: colors[NeriToken.textSecondary],
                        shape: buttonShape,
                      ),
                      child: Text(cancelLabel),
                    ),
                  PressScale(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: onColor(accent),
                        shape: buttonShape,
                      ),
                      child: Text(confirmLabel),
                    ),
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
