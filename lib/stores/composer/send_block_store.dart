import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/server/server_permissions.dart';

sealed class SendBlock {
  const SendBlock();
}

class NoSendPermission extends SendBlock {
  const NoSendPermission();
}

class SendMuted extends SendBlock {
  const SendMuted(this.until);

  final int until;
}

//null while sending is allowed
final sendBlockProvider = Provider.family<SendBlock?, String>((ref, channelId) {
  final channel = ref.watch(channelsProvider)[channelId];
  final serverId = channel?.serverId;
  if (channel == null || serverId == null) return null;

  //unknown member is left to the server
  final access = ref.watch(serverAccessProvider(serverId));
  final member = access?.member;
  if (access == null || member == null) return null;
  if (canSendMessage(access, channel)) return null;

  final until = member.muteExpireAt;
  if (!member.isMuted || until == null) return const NoSendPermission();

  //muteExpireAt changes through events, wake up on run outs
  final remaining = until - DateTime.now().millisecondsSinceEpoch;
  final timer = Timer(Duration(milliseconds: remaining), ref.invalidateSelf);
  ref.onDispose(timer.cancel);

  return SendMuted(until);
});
