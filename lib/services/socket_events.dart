import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//models
import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/models/custom_emoji.dart';
import 'package:nerimobile/models/friend.dart';
import 'package:nerimobile/models/inbox.dart';
import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/models/message_mention.dart';
import 'package:nerimobile/models/raw_server_member.dart';
import 'package:nerimobile/models/server.dart';
import 'package:nerimobile/models/server_role.dart';
import 'package:nerimobile/models/user.dart';
import 'package:nerimobile/models/user_presence.dart';
//stores
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/channel/typing_store.dart';
import 'package:nerimobile/stores/emoji/custom_emoji_store.dart';
import 'package:nerimobile/stores/inbox/inbox_store.dart';
import 'package:nerimobile/stores/message/message_mention_store.dart';
import 'package:nerimobile/stores/message/message_store.dart';
import 'package:nerimobile/stores/server/server_member_store.dart';
import 'package:nerimobile/stores/server/server_roles_store.dart';
import 'package:nerimobile/stores/server/server_store.dart';
import 'package:nerimobile/stores/user/friend_store.dart';
import 'package:nerimobile/stores/user/user_presence_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';

void handleSocketEvent(Ref ref, String event, dynamic payload) {
  switch (event) {
    case 'user:authenticated':
      onUserAuthenticated(ref, payload);
    case 'user:presence_update':
      onUserPresenceUpdate(ref, payload);
    case 'message:created':
      onMessageCreated(ref, payload);
    case 'message:updated':
      onMessageUpdated(ref, payload);
    case 'message:deleted':
      onMessageDeleted(ref, payload);
    case 'notification:dismissed':
      onNotificationDismissed(ref, payload);
    case 'inbox:opened':
      onInboxOpened(ref, payload);
    case 'inbox:closed':
      onInboxClosed(ref, payload);
    case 'channel:typing':
      onChannelTyping(ref, payload);
    case 'server:joined':
      onServerJoined(ref, payload);
    case 'server:left':
      onServerLeft(ref, payload);
    case 'server:updated':
      onServerUpdated(ref, payload);
    case 'server:channel_created':
      onServerChannelCreated(ref, payload);
    case 'server:channel_updated':
      onServerChannelUpdated(ref, payload);
    case 'server:channel_deleted':
      onServerChannelDeleted(ref, payload);
    case 'server:channel_order_updated':
      onServerChannelOrderUpdated(ref, payload);
    case 'server:channel_permissions_updated':
      onServerChannelPermissionUpdated(ref, payload);
    case 'server:role_created':
      onServerRoleCreated(ref, payload);
    case 'server:role_updated':
      onServerRoleUpdated(ref, payload);
    case 'server:role_order_updated':
      onServerRoleOrderUpdated(ref, payload);
    case 'server:role_deleted':
      onServerRoleDeleted(ref, payload);
    case 'server:member_joined':
      onServerMemberJoined(ref, payload);
    case 'server:member_left':
      onServerMemberLeft(ref, payload);
    case 'server:member_updated':
      onServerMemberUpdated(ref, payload);
    case 'server:emoji_add':
      onServerEmojiAdd(ref, payload);
    case 'server:emoji_remove':
      onServerEmojiRemove(ref, payload);
    case 'server:emoji_update':
      onServerEmojiUpdate(ref, payload);
  }
}

class AuthenticatedPayload {
  final User user;
  final List<String> orderedServerIds;
  final List<Server> servers;
  final List<CustomEmoji> customEmojis;
  final List<Channel> channels;
  final List<RawServerMember> serverMembers;
  final List<ServerRole> serverRoles;
  final List<UserPresence> presences;
  final List<MessageMention> messageMentions;
  final List<Inbox> inbox;
  final List<Friend> friends;
  final Map<String, int> lastSeenServerChannelIds;

  AuthenticatedPayload({
    required this.user,
    required this.orderedServerIds,
    required this.servers,
    required this.customEmojis,
    required this.channels,
    required this.serverMembers,
    required this.serverRoles,
    required this.presences,
    required this.messageMentions,
    required this.inbox,
    required this.friends,
    required this.lastSeenServerChannelIds,
  });

  factory AuthenticatedPayload.fromJson(
    Map<String, dynamic> json,
  ) => AuthenticatedPayload(
    user: User.fromJson(json['user']),
    orderedServerIds: List<String>.from(
      json['user']['orderedServerIds'] ?? const [],
    ),
    servers: (json['servers'] as List).map((s) => Server.fromJson(s)).toList(),
    customEmojis: [
      for (final server in (json['servers'] as List).cast<Map>())
        ..._serverEmojis(server),
    ],
    channels: (json['channels'] as List)
        .map((s) => Channel.fromJson(s))
        .toList(),
    serverMembers: (json['serverMembers'] as List)
        .map((s) => RawServerMember.fromJson(s))
        .toList(),
    serverRoles: (json['serverRoles'] as List)
        .map((s) => ServerRole.fromJson(s))
        .toList(),
    presences: (json['presences'] as List)
        .map((s) => UserPresence.fromJson(s))
        .toList(),
    messageMentions: (json['messageMentions'] as List)
        .map((s) => MessageMention.fromJson(s))
        .toList(),
    inbox: (json['inbox'] as List).map((s) => Inbox.fromJson(s)).toList(),
    friends: (json['friends'] as List).map((s) => Friend.fromJson(s)).toList(),
    lastSeenServerChannelIds: Map<String, int>.from(
      json['lastSeenServerChannelIds'],
    ),
  );
}

List<CustomEmoji> _serverEmojis(Map server) => [
  for (final emoji in (server['customEmojis'] as List? ?? const []))
    CustomEmoji.fromJson(Map<String, dynamic>.from(emoji as Map), server['id']),
];

AuthenticatedPayload _parseAuthenticatedPayload(Map<String, dynamic> json) {
  return AuthenticatedPayload.fromJson(json);
}

Future<void> onUserAuthenticated(Ref ref, dynamic payload) async {
  final data = await compute(
    _parseAuthenticatedPayload,
    payload as Map<String, dynamic>,
  );
  ref.read(serversProvider.notifier).setServers(data.servers);
  ref.read(orderedServerIdsProvider.notifier).setIds(data.orderedServerIds);
  ref.read(customEmojisProvider.notifier).setEmojis(data.customEmojis);
  ref.read(channelsProvider.notifier).setChannels(data.channels);
  ref
      .read(lastSeenServerChannelIdsProvider.notifier)
      .setLastSeenServerChannelIds(data.lastSeenServerChannelIds);
  ref.read(serverMembersProvider.notifier).setServerMembers(data.serverMembers);
  ref.read(serverRolesProvider.notifier).setServerRoles(data.serverRoles);
  ref.read(presencesProvider.notifier).addPresences(data.presences);
  ref.read(currentUserProvider.notifier).setCurrentUser(data.user);
  ref.read(messageMentionsProvider.notifier).setMentions(data.messageMentions);
  ref.read(inboxProvider.notifier).setInbox(data.inbox);
  ref.read(friendsProvider.notifier).setFriends(data.friends);
  ref.read(typingProvider.notifier).clear();
  for (final item in data.inbox) {
    ref.read(usersProvider.notifier).addUser(item.recipient);
  }
  for (final friend in data.friends) {
    ref.read(usersProvider.notifier).addUser(friend.recipient);
  }
}

void onServerJoined(Ref ref, dynamic payload) {
  final server = payload['server'] as Map<String, dynamic>;
  final serverId = server['id'] as String;

  ref
      .read(customEmojisProvider.notifier)
      .addServerEmojis(serverId, _serverEmojis(server));
  ref.read(serverRolesProvider.notifier).addServerRoles([
    for (final role in payload['roles'] as List) ServerRole.fromJson(role),
  ]);
  ref.read(channelsProvider.notifier).addChannels([
    for (final channel in payload['channels'] as List)
      Channel.fromJson(channel),
  ]);
  ref.read(serverMembersProvider.notifier).addServerMembers([
    for (final member in payload['members'] as List)
      RawServerMember.fromJson(member),
  ]);
  ref.read(presencesProvider.notifier).addPresences([
    for (final presence in payload['memberPresences'] as List? ?? const [])
      UserPresence.fromJson(presence),
  ]);
  //last so server with missing channels are never shown
  ref.read(serversProvider.notifier).addServer(Server.fromJson(server));
  ref.read(orderedServerIdsProvider.notifier).prepend(serverId);
}

void onServerLeft(Ref ref, dynamic payload) {
  final serverId = payload['serverId'] as String;

  ref.read(serversProvider.notifier).removeServer(serverId);
  ref.read(orderedServerIdsProvider.notifier).remove(serverId);
  ref.read(channelsProvider.notifier).removeServerChannels(serverId);
  ref.read(serverRolesProvider.notifier).removeServer(serverId);
  ref.read(serverMembersProvider.notifier).removeServer(serverId);
  ref.read(customEmojisProvider.notifier).removeServer(serverId);
}

void onServerOrderUpdated(Ref ref, dynamic payload) => ref
    .read(orderedServerIdsProvider.notifier)
    .setIds(List<String>.from(payload['serverIds']));

void onServerUpdated(Ref ref, dynamic payload) => ref
    .read(serversProvider.notifier)
    .updateServer(payload['serverId'], payload['updated']);

void onServerChannelCreated(Ref ref, dynamic payload) => ref
    .read(channelsProvider.notifier)
    .addChannel(Channel.fromJson(payload['channel']));

void onServerChannelUpdated(Ref ref, dynamic payload) => ref
    .read(channelsProvider.notifier)
    .updateChannel(payload['channelId'], payload['updated']);

void onServerChannelDeleted(Ref ref, dynamic payload) => ref
    .read(channelsProvider.notifier)
    .removeServerChannel(payload['channelId']);

void onServerChannelOrderUpdated(Ref ref, dynamic payload) => ref
    .read(channelsProvider.notifier)
    .updateServerChannelOrder(
      List<String>.from(payload['orderedChannelIds']),
      payload['categoryId'],
    );

void onServerChannelPermissionUpdated(Ref ref, dynamic payload) => ref
    .read(channelsProvider.notifier)
    .setChannelPermission(
      payload['channelId'],
      ChannelPermission.fromJson(payload),
    );

void onServerRoleCreated(Ref ref, dynamic payload) {
  final role = ServerRole.fromJson(payload);
  final defaultRoleId = ref.read(serversProvider)[role.serverId]?.defaultRoleId;
  ref.read(serverRolesProvider.notifier).addCreatedRole(role, defaultRoleId);
}

void onServerRoleUpdated(Ref ref, dynamic payload) => ref
    .read(serverRolesProvider.notifier)
    .updateRole(payload['serverId'], payload['roleId'], payload['updated']);

void onServerRoleOrderUpdated(Ref ref, dynamic payload) => ref
    .read(serverRolesProvider.notifier)
    .updateOrder(payload['serverId'], List<String>.from(payload['roleId']));

void onServerRoleDeleted(Ref ref, dynamic payload) {
  final serverId = payload['serverId'] as String;
  final roleId = payload['roleId'] as String;

  ref
      .read(serverMembersProvider.notifier)
      .removeRoleFromMembers(serverId, roleId);
  ref.read(channelsProvider.notifier).removeRolePermissions(serverId, roleId);
  ref.read(serverRolesProvider.notifier).removeRole(serverId, roleId);
}

void onServerMemberJoined(Ref ref, dynamic payload) => ref
    .read(serverMembersProvider.notifier)
    .addServerMembers([RawServerMember.fromJson(payload['member'])]);

void onServerMemberLeft(Ref ref, dynamic payload) => ref
    .read(serverMembersProvider.notifier)
    .removeMember(payload['serverId'], payload['userId']);

void onServerMemberUpdated(Ref ref, dynamic payload) => ref
    .read(serverMembersProvider.notifier)
    .updateMember(payload['serverId'], payload['userId'], payload['updated']);

void onServerEmojiAdd(Ref ref, dynamic payload) {
  final serverId = payload['serverId'] as String;
  ref
      .read(customEmojisProvider.notifier)
      .add(CustomEmoji.fromJson(payload['emoji'], serverId));
}

void onServerEmojiRemove(Ref ref, dynamic payload) => ref
    .read(customEmojisProvider.notifier)
    .remove(payload['serverId'], payload['emojiId']);

void onServerEmojiUpdate(Ref ref, dynamic payload) => ref
    .read(customEmojisProvider.notifier)
    .rename(payload['serverId'], payload['emojiId'], payload['name']);

void onMessageCreated(Ref ref, dynamic payload) {
  final message = Message.fromJson(payload["message"]);
  final serverId = payload["serverId"] as String?;
  final createdByMe = message.createdBy.id == ref.read(currentUserProvider)?.id;
  ref
      .read(channelsProvider.notifier)
      .updateLastMessagedAt(message.channelId, message.createdAt);

  if (createdByMe) {
    ref
        .read(lastSeenServerChannelIdsProvider.notifier)
        .updateLastSeenServerChannel(message.channelId);
  } else {
    ref.read(usersProvider.notifier).addUser(message.createdBy);

    final mentionsMe = message.mentions.any(
      (u) => u.id == ref.read(currentUserProvider)?.id,
    );
    if (serverId == null || mentionsMe) {
      ref
          .read(messageMentionsProvider.notifier)
          .increment(
            channelId: message.channelId,
            userId: message.createdBy.id,
            serverId: serverId,
          );
    }
  }

  ref.read(messagesProvider(message.channelId).notifier).addMessage(message);
  ref
      .read(typingProvider.notifier)
      .stopped(message.channelId, message.createdBy.id);
}

void onChannelTyping(Ref ref, dynamic payload) {
  ref
      .read(typingProvider.notifier)
      .started(payload['channelId'], payload['userId']);
}

void onMessageUpdated(Ref ref, dynamic payload) {
  ref
      .read(messagesProvider(payload["channelId"]).notifier)
      .updateMessage(payload["messageId"], payload["updated"]);
}

void onMessageDeleted(Ref ref, dynamic payload) {
  ref
      .read(messagesProvider(payload["channelId"]).notifier)
      .removeMessage(payload["messageId"]);
}

const notificationDismissEvent = 'notification:dismiss';

void onNotificationDismissed(Ref ref, dynamic payload) {
  final channelId = payload["channelId"] as String;
  final now = DateTime.now().millisecondsSinceEpoch;

  ref.read(messageMentionsProvider.notifier).clear(channelId);
  ref.read(inboxProvider.notifier).updateLastSeen(channelId, now);
  ref
      .read(lastSeenServerChannelIdsProvider.notifier)
      .updateLastSeenServerChannel(channelId);
}

void onInboxOpened(Ref ref, dynamic payload) {
  final channel = Channel.fromJson(payload['channel']);
  ref.read(channelsProvider.notifier).addChannel(channel);
  ref.read(usersProvider.notifier).addUser(User.fromJson(payload['recipient']));
  ref
      .read(inboxProvider.notifier)
      .addInbox(Inbox.fromJson({...payload, 'channelId': channel.id}));
}

void onInboxClosed(Ref ref, dynamic payload) {
  final channelId = payload['channelId'] as String;
  ref.read(inboxProvider.notifier).removeInbox(channelId);
  ref.read(channelsProvider.notifier).removeChannel(channelId);
}

void onUserPresenceUpdate(Ref ref, dynamic payload) {
  ref
      .read(presencesProvider.notifier)
      .updatePresence(payload["userId"], payload);
}
