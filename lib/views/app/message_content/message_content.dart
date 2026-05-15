import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import 'package:nerimobile/services/channel_service.dart';
import 'package:nerimobile/stores/channel_store.dart';
import 'package:nerimobile/stores/message_store.dart';
import 'package:nerimobile/stores/pane_size_store.dart';
import 'package:nerimobile/views/app/message_content/message_tile.dart';
import 'package:nerimobile/views/app_text_field.dart';

class MessageContent extends StatefulWidget {
  final String serverId;
  final String channelId;

  const MessageContent({
    required this.serverId,
    required this.channelId,
    super.key,
  });

  @override
  State<MessageContent> createState() => _MessageContentState();
}

class _MessageContentState extends State<MessageContent> {
  final TextEditingController inputController = TextEditingController();
  final FocusNode inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    messageStore.loadMessages(widget.channelId);
  }

  @override
  void dispose() {
    inputController.dispose();
    inputFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MessageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channelId != widget.channelId) {
      messageStore.loadMessages(widget.channelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MessageLog(
            channelId: widget.channelId,
            inputController: inputController,
            inputFocusNode: inputFocusNode,
          ),
        ),
        MessageInput(
          controller: inputController,
          focusNode: inputFocusNode,
          onSubmitted: (message) => postMessage(widget.channelId, message),
        ),
      ],
    );
  }
}

class MessageLog extends StatefulWidget {
  final String channelId;
  final TextEditingController inputController;
  final FocusNode inputFocusNode;
  const MessageLog({
    required this.channelId,
    super.key,
    required this.inputController,
    required this.inputFocusNode,
  });

  @override
  State<MessageLog> createState() => _MessageLogState();
}

class _MessageLogState extends State<MessageLog> {
  Offset? _pointerDownPosition;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Future.microtask(() {
          paneWidth.value = constraints.maxWidth;
          paneHeight.value = constraints.maxHeight;
        });
        return Watch((context) {
          final messages = messageStore.messages[widget.channelId] ?? [];
          return Listener(
            onPointerDown: (e) {
              _pointerDownPosition = e.position;
              if (!widget.inputFocusNode.hasFocus) return;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.inputFocusNode.requestFocus();
                final previousSelection = widget.inputController.selection;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.inputController.selection = previousSelection;
                });
              });
            },

            onPointerUp: (e) {
              if (_pointerDownPosition == null) return;
              final delta = (e.position - _pointerDownPosition!).distance;
              if (delta < 15) {
                widget.inputFocusNode.unfocus();
              }
            },
            child: ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final reversedIndex = messages.length - 1 - i;
                return MessageTile(
                  message: messages[reversedIndex],
                  prevMessage: reversedIndex > 0
                      ? messages[reversedIndex - 1]
                      : null,
                );
              },
            ),
          );
        });
      },
    );
  }
}

class MessageInput extends StatefulWidget {
  final ValueChanged<String> onSubmitted;
  final TextEditingController controller;
  final FocusNode focusNode;

  const MessageInput({
    super.key,
    required this.onSubmitted,
    required this.controller,
    required this.focusNode,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  void _handleSubmitted(String value) {
    widget.focusNode.requestFocus();
    if (value.trim().isEmpty) return;
    widget.onSubmitted(value);
    widget.controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Watch(
              (context) => AppTextField(
                hintText: 'Message in ${channelStore.currentChannel()?.name}',
                controller: widget.controller,
                focusNode: widget.focusNode,
                onSubmitted: _handleSubmitted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
