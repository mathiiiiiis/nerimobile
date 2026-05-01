import 'package:flutter/material.dart';
import 'package:nerimity_desktop_flutter/services/channel_service.dart';
import 'package:nerimity_desktop_flutter/stores/channel_store.dart';
import 'package:nerimity_desktop_flutter/stores/message_store.dart';
import 'package:nerimity_desktop_flutter/stores/pane_size_store.dart';
import 'package:nerimity_desktop_flutter/views/app/message_content/message_tile.dart';
import 'package:nerimity_desktop_flutter/views/app_text_field.dart';
import 'package:signals/signals_flutter.dart';

bool _isScrolling = false;

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
  @override
  void initState() {
    super.initState();
    messageStore.loadMessages(widget.channelId);
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
        Expanded(child: MessageLog(channelId: widget.channelId)),
        MessageInput(
          onSubmitted: (message) => postMessage(widget.channelId, message),
        ),
      ],
    );
  }
}

class MessageLog extends StatelessWidget {
  final String channelId;
  const MessageLog({required this.channelId, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Future.microtask(() {
          paneWidth.value = constraints.maxWidth;
          paneHeight.value = constraints.maxHeight;
        });
        return Watch((context) {
          final messages = messageStore.messages[channelId] ?? [];
          return Listener(
            onPointerDown: (_) => _isScrolling = false,
            onPointerMove: (_) => _isScrolling = true,
            onPointerUp: (_) => Future.delayed(
              const Duration(milliseconds: 100),
              () => _isScrolling = false,
            ),
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

  const MessageInput({super.key, required this.onSubmitted});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    bool ignoreNextFocusChange = false;

    _focusNode.addListener(() {
      if (ignoreNextFocusChange) {
        ignoreNextFocusChange = false;
        return;
      }
      if (!_focusNode.hasFocus) {
        _focusNode.requestFocus();
        final previousSelection = _controller.selection;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.selection = previousSelection;
        });
        Future.delayed(const Duration(milliseconds: 50), () {
          if (!_isScrolling) {
            ignoreNextFocusChange = true;
            _focusNode.unfocus();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmitted(String value) {
    _focusNode.requestFocus();
    if (value.trim().isEmpty) return;
    widget.onSubmitted(value);
    _controller.clear();
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
                controller: _controller,
                focusNode: _focusNode,
                onSubmitted: _handleSubmitted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
