import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/breakpoints.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/chat/channel/channel_header.dart';
import 'package:nerimobile/views/chat/composer/attachment_panel.dart';
import 'package:nerimobile/views/chat/composer/composer.dart';
import 'package:nerimobile/views/chat/message/message_list.dart';
import 'package:nerimobile/views/dashboard/dm_list.dart';
import 'package:nerimobile/views/shell/app_scaffold.dart';
import 'package:nerimobile/views/shell/destinations.dart';
import 'package:nerimobile/views/size_reporter.dart';

const _panelResize = Duration(milliseconds: 200);

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
        child: SafeArea(bottom: false, child: chat),
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

class _Chat extends ConsumerStatefulWidget {
  const _Chat({required this.channelId, required this.showBack});

  final String channelId;
  final bool showBack;

  @override
  ConsumerState<_Chat> createState() => _ChatState();
}

class _ChatState extends ConsumerState<_Chat> {
  double _composerHeight = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: MessageList(
            channelId: widget.channelId,
            bottomInset: _composerHeight,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ChannelHeader(
            channelId: widget.channelId,
            showBack: widget.showBack,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SizeReporter(
            onSize: (size) {
              if (mounted) setState(() => _composerHeight = size.height);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Composer(channelId: widget.channelId),
                AnimatedSize(
                  duration: _panelResize,
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: ref.watch(attachmentPickerProvider(widget.channelId))
                      ? AttachmentPanel(channelId: widget.channelId)
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
