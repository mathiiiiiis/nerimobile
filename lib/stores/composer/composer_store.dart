import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:nerimobile/services/cdn_service.dart';
import 'package:path/path.dart' as p;

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/channel_service.dart';

const maxReplies = 5;
const _typingInterval = Duration(seconds: 4);

class ComposerAttachment {
  const ComposerAttachment({
    required this.path,
    this.progress = 0,
    this.uploading = false,
  });

  final String path;
  final double progress;
  final bool uploading;

  String get name => p.basename(path);
  bool get isImage => (lookupMimeType(path) ?? '').startsWith('image/');

  ComposerAttachment copyWith({double? progress, bool? uploading}) =>
      ComposerAttachment(
        path: path,
        progress: progress ?? this.progress,
        uploading: uploading ?? this.uploading,
      );
}

class ComposerState {
  const ComposerState({
    this.replyTo = const [],
    this.mentionReplies = true,
    this.editing,
    this.pendingInsert,
    this.attachment,
  });

  final List<Message> replyTo;
  final bool mentionReplies;
  final Message? editing;
  final String? pendingInsert;
  final ComposerAttachment? attachment;

  ComposerState copyWith({
    List<Message>? replyTo,
    bool? mentionReplies,
    ValueGetter<Message?>? editing,
    ValueGetter<String?>? pendingInsert,
    ValueGetter<ComposerAttachment?>? attachment,
  }) => ComposerState(
    replyTo: replyTo ?? this.replyTo,
    mentionReplies: mentionReplies ?? this.mentionReplies,
    editing: editing != null ? editing() : this.editing,
    pendingInsert: pendingInsert != null ? pendingInsert() : this.pendingInsert,
    attachment: attachment != null ? attachment() : this.attachment,
  );
}

final composerProvider =
    NotifierProvider.family<ComposerNotifier, ComposerState, String>(
      ComposerNotifier.new,
    );

class ComposerNotifier extends Notifier<ComposerState> {
  ComposerNotifier(this.channelId);

  final String channelId;

  DateTime? _typingSentAt;
  CancelToken? _upload;

  @override
  ComposerState build() => ComposerState();

  void typing() {
    if (state.editing != null) return;

    final seenAt = _typingSentAt;
    final now = DateTime.now();
    if (seenAt != null && now.difference(seenAt) < _typingInterval) return;

    _typingSentAt = now;
    postTyping(
      ref.read(dioProvider),
      channelId,
    ).catchError((e) => debugPrint('postTyping($channelId) failed: $e'));
  }

  void resetTyping() => _typingSentAt = null;

  void attach(String path) {
    _upload?.cancel();
    _upload = null;
    state = state.copyWith(
      attachment: () => ComposerAttachment(path: path),
      editing: () => null,
    );
  }

  void removeAttachment() {
    _upload?.cancel();
    _upload = null;
    state = state.copyWith(attachment: () => null);
  }

  //uploads on send
  Future<String?> uploadAttachment() async {
    final attachment = state.attachment;
    if (attachment == null) return null;

    final cancelToken = _upload = CancelToken();
    _setAttachment(attachment.copyWith(uploading: true, progress: 0));

    try {
      final token = await fetchCdnToken(ref.read(dioProvider), channelId);
      return await uploadFile(
        ref.read(cdnDioProvider),
        channelId: channelId,
        token: token,
        path: attachment.path,
        cancelToken: cancelToken,
        onProgress: (progess) =>
            _setAttachment(state.attachment?.copyWith(progress: progess)),
      );
    } catch (e) {
      debugPrint('uploadAttachment($channelId) failed: $e');
      return null;
    } finally {
      if (identical(_upload, cancelToken)) _upload = null;
      _setAttachment(state.attachment?.copyWith(uploading: false));
    }
  }

  void _setAttachment(ComposerAttachment? attachment) =>
      state = state.copyWith(attachment: () => attachment);

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
