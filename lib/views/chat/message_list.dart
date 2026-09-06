import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/stores/message/message_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/chat/message_row.dart';

const _loadOlderThreshold = 400.0;

class MessageList extends ConsumerStatefulWidget {
  const MessageList({super.key, required this.channelId});

  final String channelId;

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagesProvidier(widget.channelId).notifier).open();
    });
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _controller.position;
    if (position.pixels < position.maxScrollExtent - _loadOlderThreshold) {
      return;
    }
    ref.read(messagesProvidier(widget.channelId).notifier).loadOlder();
  }

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final channel = ref.watch(messagesProvidier(widget.channelId));
    final messages = channel.messages;

    return ListView.builder(
      controller: _controller,
      reverse: true,
      padding: EdgeInsets.only(
        bottom: sizing.space(NeriSpacingRole.sm),
        top:
            sizing.dimen(NeriDimen.channelHeaderHeight) +
            sizing.space(NeriSpacingRole.md) * 2,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final position = messages.length - 1 - index;
        return MessageRow(
          message: messages[position],
          before: position == 0 ? null : messages[position - 1],
        );
      },
    );
  }
}
