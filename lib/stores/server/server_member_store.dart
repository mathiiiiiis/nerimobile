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

  void addServerMembers(List<RawServerMember> list) {
    final next = {
      for (final entry in state.entries) entry.key: {...entry.value},
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
      );
      state = next;
    }
  }

  void addServerMember(String serverId, ServerMember member) => state = {
    ...state,
    serverId: {...?state[serverId], member.userId: member},
  };
}
