import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/stores/toast/toast_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';

const _fade = Duration(milliseconds: 200);
const _rise = Offset(0, 0.03);

class ToastHost extends ConsumerWidget {
  const ToastHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toast = ref.watch(toastProvider);
    final sizing = context.neriSize;
    final bottom =
        MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.viewPaddingOf(context).bottom +
        sizing.space(NeriSpacingRole.xl);

    return Stack(
      children: [
        child,
        Positioned(
          left: sizing.space(NeriSpacingRole.lg),
          right: sizing.space(NeriSpacingRole.lg),
          bottom: bottom,
          child: IgnorePointer(
            child: Center(
              child: AnimatedSwitcher(
                duration: _fade,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: _rise,
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: toast == null
                    ? const SizedBox.shrink()
                    : _ToastCard(key: ValueKey(toast.id), toast: toast),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({super.key, required this.toast});

  final Toast toast;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final accent = colors[toast.alert ? NeriToken.alert : NeriToken.text];

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: sizing.dimen(NeriDimen.dialogWidth),
      ),
      child: Material(
        color: colors[NeriToken.card],
        shape: RoundedRectangleBorder(
          borderRadius: sizing.rounded(NeriRadiusRole.lg),
          side: BorderSide(
            color: colors[NeriToken.border],
            width: sizing.border(NeriBorderRole.hairline),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: sizing.space(NeriSpacingRole.sm),
            children: [
              if (toast.icon case final icon?)
                Icon(icon, size: sizing.dimen(NeriDimen.iconSm), color: accent),
              Flexible(
                child: Text(
                  toast.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.neriText[NeriTextRole.bodyMedium].copyWith(
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
