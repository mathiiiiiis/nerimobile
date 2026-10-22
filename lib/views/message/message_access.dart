import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/composer/send_block_store.dart';
import 'package:nerimobile/stores/message/message_store.dart';
import 'package:nerimobile/stores/message/upload_progress_store.dart';
import 'package:nerimobile/stores/server/server_permissions.dart';
import 'package:nerimobile/stores/user/user_store.dart';
import 'package:nerimobile/utils/permissions/role_permission_flag.dart';

class MessageAccess {
  const MessageAccess._({
    required this.own,
    required this.pending,
    required this.failed,
    required this.uploading,
    required this.isContent,
    required this.blocked,
    required this.moderator,
  });

  factory MessageAccess.read(WidgetRef ref, Message message) {
    final channel = ref.read(messagesProvider(message.channelId));
    return MessageAccess._(
      own: message.createdBy.id == ref.read(currentUserProvider)?.id,
      pending: channel.pending.contains(message.id),
      failed: channel.failed.contains(message.id),
      uploading: ref.read(uploadProgressProvider(message.id)) != null,
      isContent: message.type == MessageType.content,
      blocked: ref.read(sendBlockProvider(message.channelId)) != null,
      moderator: _moderates(ref, message.channelId),
    );
  }

  static bool _moderates(WidgetRef ref, String channelId) {
    final serverId = ref.read(channelsProvider)[channelId]?.serverId;
    if (serverId == null) return false;

    final access = ref.read(serverAccessProvider(serverId));
    return access != null &&
        memberHasPermission(access, RolePermissionFlag.manageChannels);
  }

  final bool own;
  final bool pending;
  final bool failed;
  final bool uploading;
  final bool isContent;
  final bool blocked;
  final bool moderator;

  bool get local => pending || failed;
  bool get canReply => !local && !blocked && isContent;
  bool get canQuote => !local && isContent;
  bool get canEdit => own && !local && !blocked && isContent;
  bool get canDelete => (own || moderator) && !pending;
  bool get canCancelUpload => own && uploading;
  bool get canCopyId => !local;
  bool get canCopyLink => !local;
}
