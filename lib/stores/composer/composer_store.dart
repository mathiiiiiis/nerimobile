import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/message.dart';

const maxReplies = 5;

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

  @override
  ComposerState build() => ComposerState();

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
