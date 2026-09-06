import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/models/friend.dart';

final friendsProvider = NotifierProvider<FriendsNotifier, Map<String, Friend>>(
  FriendsNotifier.new,
);

class FriendsNotifier extends Notifier<Map<String, Friend>> {
  @override
  Map<String, Friend> build() => const {};

  void setFriends(List<Friend> list) =>
      state = {for (final friend in list) friend.recipientId: friend};

  void addFriend(Friend friend) =>
      state = {...state, friend.recipientId: friend};

  void removeFriend(String recipientId) =>
      state = {...state}..remove(recipientId);
}
