import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/stores/inbox/inbox_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/presence/presence_line.dart';

class ChannelHeader extends ConsumerWidget {
  const ChannelHeader({
    super.key,
    required this.channelId,
    this.showBack = false,
    this.actions = const [],
  });

  final String channelId;
  final bool showBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final recipient = ref.watch(inboxProvider)[channelId]?.recipient;

    return Container(
      height: sizing.dimen(NeriDimen.channelHeaderHeight),
      margin: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
      padding: EdgeInsets.only(
        left: sizing.space(NeriSpacingRole.sm),
        right: sizing.space(NeriSpacingRole.xs),
      ),
      decoration: BoxDecoration(
        color: colors[NeriToken.pane],
        borderRadius: sizing.rounded(NeriRadiusRole.image),
      ),
      child: Row(
        children: [
          if (showBack)
            HeaderIconButton(
              icon: Symbols.arrow_back_rounded,
              onTap: () =>
                  context.canPop() ? context.pop() : context.go('/app'),
            ),
          if (recipient != null) ...[
            PresenceAvatar(
              user: recipient,
              size: sizing.dimen(NeriDimen.controlSize),
              surface: colors[NeriToken.pane],
            ),
            SizedBox(width: sizing.space(NeriSpacingRole.md)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recipient.username,
                    overflow: TextOverflow.ellipsis,
                    style: context.neriText[NeriTextRole.bodyLarge].copyWith(
                      color: colors[NeriToken.text],
                    ),
                  ),
                  PresenceLine(userId: recipient.id),
                ],
              ),
            ),
            ...actions,
          ],
        ],
      ),
    );
  }
}

class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final size = sizing.dimen(NeriDimen.controlSize);

    return InkWell(
      onTap: onTap,
      borderRadius: sizing.rounded(NeriRadiusRole.full),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          icon,
          size: sizing.dimen(NeriDimen.iconSm),
          color: context.neri[NeriToken.textSecondary],
        ),
      ),
    );
  }
}
