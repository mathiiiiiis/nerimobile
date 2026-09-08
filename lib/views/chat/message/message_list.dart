import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/models/message.dart';

import 'package:nerimobile/stores/message/message_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/chat/message_row.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const _loadOlderThreshold = 5;
const _animateWithin = 20;
const _scrollAlignment = 0.5;
const _scrollDuration = Duration(milliseconds: 250);
const _flashDuration = Duration(seconds: 1);

class MessageList extends ConsumerStatefulWidget {
  const MessageList({super.key, required this.channelId});

  final String channelId;

  @override
  ConsumerState<MessageList> createState() => MessageListState();
}

class MessageListState extends ConsumerState<MessageList> {
  final _scroll = ItemScrollController();
  final _positions = ItemPositionsListener.create();

  Timer? _flash;
  String? _flashed;

  @override
  void initState() {
    super.initState();
    _positions.itemPositions.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagesProvider(widget.channelId).notifier).open();
    });
  }

  @override
  void dispose() {
    _flash?.cancel();
    _positions.itemPositions.removeListener(_onScroll);
    super.dispose();
  }

  List<Message> get _messages =>
      ref.read(messagesProvider(widget.channelId)).messages;

  void _onScroll() {
    final positions = _positions.itemPositions.value;
    if (positions.isEmpty) return;

    final oldest = positions
        .map((p) => p.index)
        .reduce((a, b) => a > b ? a : b);
    if (oldest < _messages.length - _loadOlderThreshold) return;

    ref.read(messagesProvider(widget.channelId).notifier).loadOlder();
  }

  bool _isFullyVisible(int index) {
    for (final position in _positions.itemPositions.value) {
      if (position.index != index) continue;
      return position.itemLeadingEdge >= 0 && position.itemTrailingEdge <= 1;
    }
    return false;
  }

  //TODO: fetch with aroud when target is outside the loaded window
  void scrollToMessage(String messageId) {
    final messages = _messages;
    final target = messages.indexWhere((m) => m.id == messageId);
    if (target == -1) return;

    final index = messages.length - 1 - target;
    final visible = _positions.itemPositions.value;
    final from = visible.isEmpty ? index : visible.first.index;

    _flash?.cancel();
    setState(() => _flashed = messageId);
    _flash = Timer(_flashDuration, () {
      if (mounted) setState(() => _flashed = null);
    });

    if (_isFullyVisible(index)) return;

    if ((index - from).abs() > _animateWithin) {
      _scroll.jumpTo(index: index, alignment: _scrollAlignment);
      return;
    }
    _scroll.scrollTo(
      index: index,
      duration: _scrollDuration,
      alignment: _scrollAlignment,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final channel = ref.watch(messagesProvider(widget.channelId));
    final messages = channel.messages;

    return ScrollablePositionedList.builder(
      itemScrollController: _scroll,
      itemPositionsListener: _positions,
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
          flashed: messages[position].id == _flashed,
        );
      },
    );
  }
}
