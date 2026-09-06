import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/channel_service.dart';

const messagePageSize = 50;

@immutable
class ChannelMessages {
  const ChannelMessages({
    this.messages = const [],
    this.loaded = false,
    this.loading = false,
    this.hasMore = true,
  });

  final List<Message> messages;
  final bool loaded;
  final bool loading;
  final bool hasMore;

  Message? get newest => messages.isEmpty ? null : messages.last;
  Message? get oldest => messages.isEmpty ? null : messages.first;

  ChannelMessages copyWith({
    List<Message>? messages,
    bool? loaded,
    bool? loading,
    bool? hasMore,
  }) => ChannelMessages(
    messages: messages ?? this.messages,
    loaded: loaded ?? this.loaded,
    loading: loading ?? this.loading,
    hasMore: hasMore ?? this.hasMore,
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
