import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/services/socket_events.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/connection/connection_store.dart';
import 'package:nerimobile/stores/inbox/inbox_store.dart';
import 'package:nerimobile/stores/message/message_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';
import 'package:nerimobile/stores/window/window_focus_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/views/chat/channel/channel_header.dart';
import 'package:nerimobile/views/chat/file_too_large_dialog.dart';
import 'package:nerimobile/views/chat/message/message_list_skeleton.dart';
import 'package:nerimobile/views/chat/message/message_row.dart';
import 'package:nerimobile/views/scroll_jump_button.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const _loadOlderThreshold = 5;
const _animateWithin = 20;
const _scrollAlignment = 0.5;
const _scrollDuration = Duration(milliseconds: 250);
const _flashDuration = Duration(seconds: 1);
const _jumpShowsFrom = 5;

class MessageList extends ConsumerStatefulWidget {
  const MessageList({super.key, required this.channelId, this.bottomInset = 0});

  final String channelId;
  final double bottomInset;

  @override
  ConsumerState<MessageList> createState() => MessageListState();
}

class MessageListState extends ConsumerState<MessageList> {
  final _scroll = ItemScrollController();
  final _positions = ItemPositionsListener.create();

  Timer? _flash;
  String? _flashed;

  int? _lastSeen;

  var _scrolledUp = false;
  var _missed = 0;
  double? _heldPadding;
  var _pinned = false;
  double? _viewport;

  @override
  void initState() {
    super.initState();
    _positions.itemPositions.addListener(_onScroll);
    _lastSeen = _readLastSeen();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagesProvider(widget.channelId).notifier).open();
    });
  }

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channelId == widget.channelId) return;

    _dismissed = false;
    _flash?.cancel();
    _flashed = null;
    _scrolledUp = false;
    _missed = 0;
    _heldPadding = null;
    _pinned = false;
    _lastSeen = _readLastSeen();
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

  int? _readLastSeen() {
    final inbox = ref.read(inboxProvider)[widget.channelId];
    if (inbox != null) return inbox.lastSeen;
    return ref.read(lastSeenServerChannelIdsProvider)?[widget.channelId];
  }

  void _clearUnread() {
    setState(() => _lastSeen = null);
    _dismissed = false;
    _dismissNow();
  }

  bool _startsUnread(Message message, Message? before) {
    final seen = _lastSeen;
    if (seen == null) return false;
    if (message.createdBy.id == ref.read(currentUserProvider)?.id) return false;
    if (message.createdAt <= seen) return false;
    return before == null || before.createdAt <= seen;
  }

  List<Message> get _messages =>
      ref.read(messagesProvider(widget.channelId)).messages;

  bool _dismissed = false;

  void _dismiss() {
    _dismissed = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => _dismissNow());
  }

  void _dismissNow() {
    if (!mounted) return;
    if (!ref.read(windowFocusProvider)) return;
    if (!_atBottom || _dismissed) return;

    _dismissed = true;
    ref.read(connectionProvider.notifier).send(notificationDismissEvent, {
      'channelId': widget.channelId,
    });
  }

  bool get _atBottom {
    final positions = _positions.itemPositions.value;
    if (positions.isEmpty) return false;

    final newest = positions
        .map((p) => p.index)
        .reduce((a, b) => a < b ? a : b);
    return newest == 0;
  }

  void _onScroll() {
    final positions = _positions.itemPositions.value;
    if (positions.isEmpty) return;

    if (!_atBottom) _dismissed = false;
    _dismissNow();
    _updateJump(positions);
    _holdPadding();
    _unpinAtNewest(positions);

    final oldest = positions
        .map((p) => p.index)
        .reduce((a, b) => a > b ? a : b);
    if (oldest < _messages.length - _loadOlderThreshold) return;

    ref.read(messagesProvider(widget.channelId).notifier).loadOlder();
  }

  void _updateJump(Iterable<ItemPosition> positions) {
    final newest = positions
        .map((p) => p.index)
        .reduce((a, b) => a < b ? a : b);
    final scrolledUp = newest >= _jumpShowsFrom;
    final missed = newest == 0 ? 0 : _missed;
    if (scrolledUp == _scrolledUp && missed == _missed) return;

    setState(() {
      _scrolledUp = scrolledUp;
      _missed = missed;
    });
  }

  double get _livePadding =>
      widget.bottomInset + context.neriSize.space(NeriSpacingRole.xl);

  double get _bottomPadding => _heldPadding ?? _livePadding;

  void _holdPadding() {
    if (!_atBottom) {
      _heldPadding ??= _livePadding;
      return;
    }
    if (_heldPadding != null) setState(() => _heldPadding = null);
  }

  void _keepPlace(ChannelMessages? previous, ChannelMessages next) {
    final lastId = previous?.messages.lastOrNull?.id;
    if (previous == null || lastId == null || _atBottom) return;

    final at = next.messages.indexWhere((m) => m.id == lastId);
    final added = next.messages.length - 1 - at;
    if (at == -1 || added <= 0) return;

    if (next.messages.last.createdBy.id == ref.read(currentUserIdProvider)) {
      _scroll.jumpTo(index: 0);
      return;
    }

    final visible = _positions.itemPositions.value;
    if (visible.isEmpty) return;
    final anchor = visible.reduce((a, b) => a.index < b.index ? a : b);
    if (anchor.index + added > previous.messages.length - 1) return;

    _pinned = true;
    _scroll.jumpTo(
      index: anchor.index + added,
      alignment: anchor.itemLeadingEdge,
    );
  }

  void _unpinAtNewest(Iterable<ItemPosition> positions) {
    final viewport = _viewport;
    if (!_pinned || viewport == null) return;

    final newest = positions.where((p) => p.index == 0).firstOrNull;
    if (newest == null) return;
    if (newest.itemLeadingEdge * viewport > _bottomPadding + 1) return;

    _pinned = false;
    _scroll.jumpTo(index: 0);
  }

  void _jumpToNewest(double viewport) {
    final visible = _positions.itemPositions.value;
    final from = visible.isEmpty ? 0 : visible.first.index;
    _pinned = false;
    setState(() => _missed = 0);

    if (from > _animateWithin) {
      _scroll.jumpTo(index: 0);
      return;
    }
    _scroll.scrollTo(
      index: 0,
      alignment: _bottomPadding / viewport,
      duration: _scrollDuration,
    );
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
    _pinned = index != 0;

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

  Future<void> _retry(String localId) async {
    final failure = await ref
        .read(messagesProvider(widget.channelId).notifier)
        .retry(localId);
    if (failure == SendFailure.fileTooLarge && mounted) {
      showFileTooLargeDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(windowFocusProvider, (_, focused) {
      if (focused) _dismiss();
    });
    ref.listen(connectionProvider, (previous, next) {
      if (next is Authenticated && next.reconnected) {
        ref.read(messagesProvider(widget.channelId).notifier).reconcile();
      }
    });
    ref.listen(messagesProvider(widget.channelId), (previous, next) {
      if (next.messages.length != previous?.messages.length) _dismiss();
      _keepPlace(previous, next);

      final newest = next.messages.lastOrNull?.id;
      if (!_scrolledUp || newest == previous?.messages.lastOrNull?.id) return;
      if (next.messages.last.createdBy.id == ref.read(currentUserIdProvider)) {
        return;
      }
      setState(() => _missed++);
    });

    final sizing = context.neriSize;
    final channel = ref.watch(messagesProvider(widget.channelId));
    final messages = channel.messages;

    if (!channel.loaded && messages.isEmpty) {
      return MessageListSkeleton(bottomInset: widget.bottomInset);
    }

    final list = ScrollablePositionedList.builder(
      itemScrollController: _scroll,
      itemPositionsListener: _positions,
      reverse: true,
      padding: EdgeInsets.only(
        bottom: _bottomPadding,
        top: channelHeaderExtent(context),
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final position = messages.length - 1 - index;
        final message = messages[position];
        final before = position == 0 ? null : messages[position - 1];

        return MessageRow(
          unread: _startsUnread(message, before),
          onClearUnread: _clearUnread,
          message: message,
          before: before,
          pending:
              channel.pending.contains(message.id) ||
              channel.editing.contains(message.id),
          failed: channel.failed.contains(message.id),
          onRetry: () => _retry(message.id),
          flashed: message.id == _flashed,
        );
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.maxHeight;
        return Stack(
          children: [
            list,
            Positioned(
              right: sizing.space(NeriSpacingRole.md),
              bottom: widget.bottomInset + sizing.space(NeriSpacingRole.md),
              child: ScrollJumpButton(
                shown: _scrolledUp,
                icon: Symbols.arrow_downward_rounded,
                count: _missed,
                onTap: () => _jumpToNewest(constraints.maxHeight),
              ),
            ),
          ],
        );
      },
    );
  }
}
