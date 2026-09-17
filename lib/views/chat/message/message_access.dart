import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/stores/message/message_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';

class MessageAccess {
  const MessageAccess._({
    required this.own,
    required this.pending,
    required this.failed,
    required this.isContent,
  });

  factory MessageAccess.read(WidgetRef ref, Message message) {
    final channel = ref.read(messagesProvider(message.channelId));
    return MessageAccess._(
      own: message.createdBy.id == ref.read(currentUserProvider)?.id,
      pending: channel.pending.contains(message.id),
      failed: channel.failed.contains(message.id),
      isContent: message.type == MessageType.content,
    );
  }

  final bool own;
  final bool pending;
  final bool failed;
  final bool isContent;

  bool get local => pending || failed;
  bool get canReply => !local && isContent;
  bool get canQuote => !local;
  bool get canEdit => own && !local && isContent;
  bool get canDelete => own && !pending && isContent;
  bool get canCopyId => !local;
}
