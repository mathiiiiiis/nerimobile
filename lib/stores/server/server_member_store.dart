import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/models/raw_server_member.dart';
import 'package:nerimobile/models/server_member.dart';
import 'package:nerimobile/stores/user/user_store.dart';

final serverMembersProvider =
    NotifierProvider<
      ServerMembersNotifier,
      Map<String, Map<String, ServerMember>>
    >(ServerMembersNotifier.new);

class ServerMembersNotifier
    extends Notifier<Map<String, Map<String, ServerMember>>> {
  @override
  Map<String, Map<String, ServerMember>> build() => const {};

  void setServerMembers(List<RawServerMember> list) =>
      state = _merged(const {}, list);

  void addServerMembers(List<RawServerMember> list) =>
      state = _merged(state, list);

  Map<String, Map<String, ServerMember>> _merged(
    Map<String, Map<String, ServerMember>> base,
    List<RawServerMember> list,
  ) {
    final next = {
      for (final entry in base.entries) entry.key: {...entry.value},
    };
    final users = ref.read(usersProvider.notifier);

    for (final raw in list) {
      users.addUser(raw.user);
      (next[raw.serverId] ??= {})[raw.userId] = ServerMember(
        id: raw.id,
        userId: raw.userId,
        serverId: raw.serverId,
        roleIds: raw.roleIds,
        nickname: raw.nickname,
        muteExpireAt: raw.muteExpireAt,
      );
    }
    return next;
  }

  void addServerMember(String serverId, ServerMember member) => state = {
    ...state,
    serverId: {...?state[serverId], member.userId: member},
  };

  void removeServer(String serverId) => state = {...state}..remove(serverId);
}
