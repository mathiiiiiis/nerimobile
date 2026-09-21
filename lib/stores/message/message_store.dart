import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/cdn_service.dart';
import 'package:nerimobile/services/channel_service.dart';
import 'package:nerimobile/stores/message/upload_progress_store.dart';
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
    this.editing = const {},
  });

  final List<Message> messages;
  final bool loaded;
  final bool loading;
  final bool hasMore;
  final Set<String> pending;
  final Set<String> failed;
  final Set<String> editing;

  Message? get newest => messages.isEmpty ? null : messages.last;
  Message? get oldest => messages.isEmpty ? null : messages.first;

  ChannelMessages copyWith({
    List<Message>? messages,
    bool? loaded,
    bool? loading,
    bool? hasMore,
    Set<String>? pending,
    Set<String>? failed,
    Set<String>? editing,
  }) => ChannelMessages(
    messages: messages ?? this.messages,
    loaded: loaded ?? this.loaded,
    loading: loading ?? this.loading,
    hasMore: hasMore ?? this.hasMore,
    pending: pending ?? this.pending,
    failed: failed ?? this.failed,
    editing: editing ?? this.editing,
  );
}

final messagesProvider =
    NotifierProvider.family<MessagesNotifier, ChannelMessages, String>(
      MessagesNotifier.new,
    );

class MessagesNotifier extends Notifier<ChannelMessages> {
  MessagesNotifier(this.channelId);

  final String channelId;

  final _mentionReplies = <String>{};

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

  Future<void> reconcile() async {
    final oldest = state.oldest;
    if (!state.loaded || oldest == null) return;

    final floor = BigInt.parse(oldest.id);
    final server = <Message>[];
    String? cursor;

    while (true) {
      final batch = await _fetch(limit: messagePageSize, before: cursor);
      if (batch == null) return;

      server.addAll(batch);
      if (batch.length < messagePageSize) break;

      cursor = _sorted(batch).first.id;
      if (BigInt.parse(cursor) <= floor) break;
    }

    state = state.copyWith(messages: _reconciled(server, floor));
  }

  List<Message> _reconciled(List<Message> server, BigInt floor) {
    final local = {...state.pending, ...state.failed};

    return _sorted([
      for (final message in server)
        if (BigInt.parse(message.id) >= floor) message,
      for (final message in state.messages)
        if (local.contains(message.id)) message,
    ]);
  }

  Future<void> send(
    String content, {
    List<PartialMessage> replyTo = const [],
    bool mentionReplies = false,
    String? file,
  }) async {
    final author = ref.read(currentUserProvider);
    if (author == null) return;

    final localId = _localId();
    final local = Message(
      id: localId,
      content: content,
      channelId: channelId,
      createdBy: author,
      attachments: [
        if (file != null) Attachment(id: localId, path: file, onDevice: true),
      ],
      createdAt: DateTime.now().millisecondsSinceEpoch,
      replyMessages: [
        for (final reply in replyTo) ReplyMessage(replyToMessage: reply),
      ],
    );

    if (mentionReplies) _mentionReplies.add(localId);
    state = state.copyWith(
      messages: [...state.messages, local],
      pending: {...state.pending, localId},
    );

    try {
      final fileId = file == null ? null : await _upload(file, localId);
      final sent = await postMessage(
        ref.read(dioProvider),
        channelId,
        content,
        replyToMessageIds: [for (final reply in replyTo) reply.id],
        mentionReplies: mentionReplies,
        fileId: fileId,
      );
      _mentionReplies.remove(localId);
      _replaceLocal(localId, Message.fromJson(sent['message'] ?? sent));
    } catch (e) {
      final reason = e is DioException ? e.response?.data : null;
      debugPrint('postMessage($channelId) failed: {$reason ?? e}');
      state = state.copyWith(
        pending: {...state.pending}..remove(localId),
        failed: {...state.failed, localId},
      );
    }
  }

  void retry(String localId) {
    final local = _find(localId);
    if (local == null) return;

    final mentionReplies = _mentionReplies.contains(localId);
    _remove(localId);
    send(
      local.content,
      replyTo: [for (final reply in local.replyMessages) ?reply.replyToMessage],
      mentionReplies: mentionReplies,
      file: local.attachments.firstOrNull?.path,
    );
  }

  Future<String> _upload(String file, String localId) async {
    final provider = uploadProgressProvider(localId);
    final hold = ref.listen(provider, (_, _) {});
    final progress = ref.read(provider.notifier)..report(0);

    try {
      final token = await fetchCdnToken(ref.read(dioProvider), channelId);
      return await uploadFile(
        ref.read(cdnDioProvider),
        channelId: channelId,
        token: token,
        path: file,
        onProgress: progress.report,
      );
    } finally {
      progress.report(null);
      hold.close();
    }
  }

  Future<bool> edit(String messageId, String content) async {
    if (_isLocal(messageId)) return false;

    final original = _find(messageId);
    if (original == null) return false;
    if (original.content == content) return true;

    _replace(original.copyWith({'content': content}));
    state = state.copyWith(editing: {...state.editing, messageId});

    try {
      final updated = await patchMessage(
        ref.read(dioProvider),
        channelId,
        messageId,
        content,
      );
      updateMessage(messageId, updated);
      return true;
    } catch (e) {
      debugPrint('patchMessage($channelId, $messageId) failed: $e');
      final current = _find(messageId);
      if (current != null) {
        _replace(current.copyWith({'content': original.content}));
      }
      return false;
    } finally {
      state = state.copyWith(editing: {...state.editing}..remove(messageId));
    }
  }

  Future<bool> delete(String messageId) async {
    if (state.pending.contains(messageId)) return false;
    if (state.failed.contains(messageId)) {
      _remove(messageId);
      return true;
    }

    final original = _find(messageId);
    if (original == null) return false;
    removeMessage(messageId);

    try {
      await deleteMessage(ref.read(dioProvider), channelId, messageId);
      return true;
    } catch (e) {
      debugPrint('deleteMessage($channelId, $messageId) failed: $e');
      addMessage(original);
      return false;
    }
  }

  void addMessage(Message message) {
    if (state.messages.any((m) => m.id == message.id)) return;
    state = state.copyWith(messages: _merge([message]));
  }

  void updateMessage(String messageId, Map<String, dynamic> partial) {
    final message = _find(messageId);
    if (message == null) return;
    _replace(message.copyWith(partial));
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

  bool _isLocal(String messageId) =>
      state.pending.contains(messageId) || state.failed.contains(messageId);

  Message? _find(String messageId) =>
      state.messages.where((m) => m.id == messageId).firstOrNull;

  void _replace(Message message) {
    final index = state.messages.indexWhere((m) => m.id == message.id);
    if (index == -1) return;

    final updated = List<Message>.from(state.messages);
    updated[index] = message;
    state = state.copyWith(messages: updated);
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

  void _remove(String localId) {
    _mentionReplies.remove(localId);
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != localId).toList(),
      pending: {...state.pending}..remove(localId),
      failed: {...state.failed}..remove(localId),
    );
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
