import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/views/chat/channel_header.dart';
import 'package:nerimobile/views/chat/message_list.dart';
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

    if (!dualPane) return SafeArea(child: chat);

    return AppScaffold(
      branch: NeriBranch.dashboard,
      listPane: const DmListPane(),
      content: chat,
    );
  }
}

class _Chat extends StatelessWidget {
  const _Chat({required this.channelId, required this.showBack});

  final String channelId;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.neri[NeriToken.background],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChannelHeader(
            channelId: channelId,
            showBack: !NeriWindow.of(context).isDualPane,
          ),
          Expanded(child: MessageList(channelId: channelId)),
        ],
      ),
    );
  }
}
