import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/channel_service.dart';
import 'package:nerimobile/stores/user/user_store.dart';

const messagePageSize = 50;

//pending messages sort last
String _localId() => '999${DateTime.now().microsecondsSinceEpoch}';

@immutable
class ChannelMessages {
  const ChannelMessages({
    this.messages = const [],
    this.loaded = false,
    this.loading = false,
    this.hasMore = true,
    this.pending = const {},
    this.failed = const {},
  });

  final List<Message> messages;
  final bool loaded;
  final bool loading;
  final bool hasMore;
  final Set<String> pending;
  final Set<String> failed;

  Message? get newest => messages.isEmpty ? null : messages.last;
  Message? get oldest => messages.isEmpty ? null : messages.first;

  ChannelMessages copyWith({
    List<Message>? messages,
    bool? loaded,
    bool? loading,
    bool? hasMore,
    Set<String>? pending,
    Set<String>? failed,
  }) => ChannelMessages(
    messages: messages ?? this.messages,
    loaded: loaded ?? this.loaded,
    loading: loading ?? this.loading,
    hasMore: hasMore ?? this.hasMore,
    pending: pending ?? this.pending,
    failed: failed ?? this.failed,
  );
}

final messagesProvider =
    NotifierProvider.family<MessagesNotifier, ChannelMessages, String>(
      MessagesNotifier.new,
    );

class MessagesNotifier extends Notifier<ChannelMessages> {
  MessagesNotifier(this.channelId);

  final String channelId;

  @override
  ChannelMessages build() => const ChannelMessages();

  Future<void> open() async {
    if (state.loaded) return catchUp();
    await loadInitial();
  }

  Future<void> loadInitial() async {
    if (state.loading) return;
    state = state.copyWith(loading: true);

    final batch = await _fetch(limit: messagePageSize);
    state = state.copyWith(
      messages: batch == null ? state.messages : _sorted(batch),
      loaded: batch != null,
      loading: false,
      hasMore: (batch?.length ?? 0) == messagePageSize,
    );
  }

  Future<void> loadOlder() async {
    final oldest = state.oldest;
    if (state.loading || !state.hasMore || oldest == null) return;
    state = state.copyWith(loaded: true);

    final batch = await _fetch(limit: messagePageSize, before: oldest.id);
    state = state.copyWith(
      messages: batch == null ? state.messages : _merge(batch),
      loading: false,
      hasMore: (batch?.length ?? 0) == messagePageSize,
    );
  }

  Future<void> catchUp() async {
    var cursor = state.newest?.id;
    if (cursor == null) return;

    while (true) {
      final batch = await _fetch(limit: messagePageSize, after: cursor);
      if (batch == null || batch.isEmpty) return;

      state = state.copyWith(messages: _merge(batch));
      cursor = _sorted(batch).last.id;
      if (batch.length < messagePageSize) return;
    }
  }

  Future<void> send(String content) async {
    final author = ref.read(currentUserProvider);
    if (author == null) return;

    final localId = _localId();
    final local = Message(
      id: localId,
      content: content,
      channelId: channelId,
      createdBy: author,
      attachments: const [],
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    state = state.copyWith(
      messages: [...state.messages, local],
      pending: {...state.pending, localId},
    );

    try {
      final sent = await postMessage(ref.read(dioProvider), channelId, content);
      _replaceLocal(localId, Message.fromJson(sent['message'] ?? sent));
    } catch (e) {
      debugPrint('postMessage($channelId) failed: $e');
      state = state.copyWith(
        pending: {...state.pending}..remove(localId),
        failed: {...state.failed, localId},
      );
    }
  }

  void retry(String localId) {
    final local = state.messages.where((m) => m.id == localId).firstOrNull;
    if (local == null) return;

    _remove(localId);
    send(local.content);
  }

  void addMessage(Message message) {
    if (state.messages.any((m) => m.id == message.id)) return;
    state = state.copyWith(messages: _merge([message]));
  }

  void updateMessage(String messageId, Map<String, dynamic> partial) {
    final index = state.messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final updated = List<Message>.from(state.messages);
    updated[index] = updated[index].copyWith(partial);
    state = state.copyWith(messages: updated);
  }

  void removeMessage(String messageId) => state = state.copyWith(
    messages: state.messages.where((m) => m.id != messageId).toList(),
  );

  Future<List<Message>?> _fetch({
    required int limit,
    String? before,
    String? after,
  }) async {
    try {
      return await fetchMessages(
        ref.read(dioProvider),
        channelId,
        limit: limit,
        before: before,
        after: after,
      );
    } catch (e) {
      debugPrint('fetchMessages($channelId) failed: $e');
      return null;
    }
  }

  void _replaceLocal(String localId, Message sent) {
    state = state.copyWith(
      messages: _sorted([
        ...state.messages.where((m) => m.id != localId),
        if (!state.messages.any((m) => m.id == sent.id)) sent,
      ]),
      pending: {...state.pending}..remove(localId),
    );
  }

  void _remove(String localId) => state = state.copyWith(
    messages: state.messages.where((m) => m.id != localId).toList(),
    pending: {...state.pending}..remove(localId),
    failed: {...state.failed}..remove(localId),
  );

  List<Message> _merge(List<Message> batch) {
    final byId = {for (final m in state.messages) m.id: m};
    for (final message in batch) {
      byId[message.id] = message;
    }
    return _sorted(byId.values.toList());
  }

  static List<Message> _sorted(List<Message> messages) =>
      messages
        ..sort((a, b) => BigInt.parse(a.id).compareTo(BigInt.parse(b.id)));
}
