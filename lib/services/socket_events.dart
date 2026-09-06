import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//models
import 'package:nerimobile/models/channel.dart';
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
  }
}

class AuthenticatedPayload {
  final User user;
  final List<Server> servers;
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
    required this.servers,
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
    servers: (json['servers'] as List).map((s) => Server.fromJson(s)).toList(),
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

AuthenticatedPayload _parseAuthenticatedPayload(Map<String, dynamic> json) {
  return AuthenticatedPayload.fromJson(json);
}

Future<void> onUserAuthenticated(Ref ref, dynamic payload) async {
  final data = await compute(
    _parseAuthenticatedPayload,
    payload as Map<String, dynamic>,
  );
  ref.read(serversProvider.notifier).addServers(data.servers);
  ref.read(channelsProvider.notifier).addChannels(data.channels);
  ref
      .read(lastSeenServerChannelIdsProvider.notifier)
      .setLastSeenServerChannelIds(data.lastSeenServerChannelIds);
  ref.read(serverMembersProvider.notifier).addServerMembers(data.serverMembers);
  ref.read(serverRolesProvider.notifier).addServerRoles(data.serverRoles);
  ref.read(presencesProvider.notifier).addPresences(data.presences);
  ref.read(currentUserProvider.notifier).setCurrentUser(data.user);
  ref.read(messageMentionsProvider.notifier).setMentions(data.messageMentions);
  ref.read(inboxProvider.notifier).setInbox(data.inbox);
  ref.read(friendsProvider.notifier).setFriends(data.friends);
  for (final item in data.inbox) {
    ref.read(usersProvider.notifier).addUser(item.recipient);
  }
  for (final friend in data.friends) {
    ref.read(usersProvider.notifier).addUser(friend.recipient);
  }
}

void onMessageCreated(Ref ref, dynamic payload) {
  final message = Message.fromJson(payload["message"]);
  final channel = ref.read(channelsProvider)[message.channelId];
  final createdByMe = message.createdBy.id == ref.read(currentUserProvider)?.id;
  if (channel != null && !createdByMe) {
    ref
        .read(channelsProvider.notifier)
        .updateLastMessagedAt(message.channelId, message.createdAt);
  }
  ref.read(messageProvidier.notifier).addMessage(message.channelId, message);
}

void onMessageUpdated(Ref ref, dynamic payload) {
  ref
      .read(messageProvidier.notifier)
      .updateMessage(
        payload["channelId"],
        payload["messageId"],
        payload["updated"],
      );
}

void onMessageDeleted(Ref ref, dynamic payload) {
  ref
      .read(messageProvidier.notifier)
      .removeMessage(payload["channelId"], payload["messageId"]);
}

void onNotificationDismissed(Ref ref, dynamic payload) {
  ref
      .read(lastSeenServerChannelIdsProvider.notifier)
      .updateLastSeenServerChannel(payload["channelId"]);
}

void onUserPresenceUpdate(Ref ref, dynamic payload) {
  ref
      .read(presencesProvider.notifier)
      .updatePresence(payload["userId"], payload);
}
