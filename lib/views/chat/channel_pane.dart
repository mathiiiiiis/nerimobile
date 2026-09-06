import 'package:flutter/material.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/views/chat/channel_header.dart';
import 'package:nerimobile/views/shell/widgets/panes.dart';

class ChannelPane extends StatelessWidget {
  const ChannelPane({super.key, required this.channelId});

  final String channelId;

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
          const Expanded(child: PlaceholderPane(label: 'Messages')),
        ],
      ),
    );
  }
}
