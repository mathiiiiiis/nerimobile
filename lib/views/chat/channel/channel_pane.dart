import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/chat/channel/channel_header.dart';
import 'package:nerimobile/views/chat/composer/composer.dart';
import 'package:nerimobile/views/chat/message/message_list.dart';
import 'package:nerimobile/views/dashboard/dm_list.dart';
import 'package:nerimobile/views/shell/app_scaffold.dart';
import 'package:nerimobile/views/shell/destinations.dart';

class ChannelPane extends StatelessWidget {
  const ChannelPane({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context) {
    final dualPane = NeriWindow.of(context).isDualPane;
    final chat = _Chat(channelId: channelId, showBack: !dualPane);
    final sizing = context.neriSize;

    if (!dualPane) {
      return ColoredBox(
        color: context.neri[NeriToken.background],
        child: SafeArea(child: chat),
      );
    }

    return AppScaffold(
      branch: NeriBranch.dashboard,
      listPane: const DmListPane(),
      content: Padding(
        padding: EdgeInsets.only(
          top: sizing.space(NeriSpacingRole.sm),
          right: sizing.space(NeriSpacingRole.sm),
          bottom: sizing.space(NeriSpacingRole.sm),
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.neri[NeriToken.background],
            borderRadius: sizing.rounded(NeriRadiusRole.md),
            border: Border.all(
              color: context.neri[NeriToken.border],
              width: sizing.border(NeriBorderRole.hairline),
            ),
          ),
          child: chat,
        ),
      ),
    );
  }
}

class _Chat extends StatelessWidget {
  const _Chat({required this.channelId, required this.showBack});

  final String channelId;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: MessageList(channelId: channelId)),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ChannelHeader(channelId: channelId, showBack: showBack),
              ),
            ],
          ),
        ),
        Composer(channelId: channelId),
      ],
    );
  }
}
