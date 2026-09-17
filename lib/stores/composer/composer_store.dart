import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/channel_service.dart';

const maxReplies = 5;
const _typingInterval = Duration(seconds: 4);

class ComposerState {
  const ComposerState({
    this.replyTo = const [],
    this.mentionReplies = true,
    this.editing,
    this.pendingInsert,
  });

  final List<Message> replyTo;
  final bool mentionReplies;
  final Message? editing;
  final String? pendingInsert;

  ComposerState copyWith({
    List<Message>? replyTo,
    bool? mentionReplies,
    ValueGetter<Message?>? editing,
    ValueGetter<String?>? pendingInsert,
  }) => ComposerState(
    replyTo: replyTo ?? this.replyTo,
    mentionReplies: mentionReplies ?? this.mentionReplies,
    editing: editing != null ? editing() : this.editing,
    pendingInsert: pendingInsert != null ? pendingInsert() : this.pendingInsert,
  );
}

final composerProvider =
    NotifierProvider.family<ComposerNotifier, ComposerState, String>(
      ComposerNotifier.new,
    );

class ComposerNotifier extends Notifier<ComposerState> {
  ComposerNotifier(this.channelId);

  final String channelId;

  DateTime? _typingSeenAt;

  @override
  ComposerState build() => ComposerState();

  void typing() {
    if (state.editing != null) return;

    final seenAt = _typingSeenAt;
    final now = DateTime.now();
    if (seenAt != null && now.difference(seenAt) < _typingInterval) return;

    _typingSeenAt = now;
    postTyping(
      ref.read(dioProvider),
      channelId,
    ).catchError((e) => debugPrint('postTyping($channelId) failed: $e'));
  }

  void resetTyping() => _typingSeenAt = null;

  void reply(Message message) {
    final replyTo = state.replyTo;
    if (replyTo.length >= maxReplies) return;
    if (replyTo.any((m) => m.id == message.id)) return;

    state = state.copyWith(replyTo: [...replyTo, message], editing: () => null);
  }

  void removeReply(String messageId) => state = state.copyWith(
    replyTo: state.replyTo.where((m) => m.id != messageId).toList(),
  );

  void clearReplies() => state = state.copyWith(replyTo: const []);

  void toggleMentionReplies() =>
      state = state.copyWith(mentionReplies: !state.mentionReplies);

  void edit(Message message) =>
      state = state.copyWith(replyTo: const [], editing: () => message);

  void cancelEdit() => state = state.copyWith(editing: () => null);

  void insert(String text) => state = state.copyWith(pendingInsert: () => text);

  String? takeInsert() {
    final text = state.pendingInsert;
    if (text != null) state = state.copyWith(pendingInsert: () => null);
    return text;
  }
}
