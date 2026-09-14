import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/user.dart';
import 'package:nerimobile/models/user_presence.dart';
import 'package:nerimobile/stores/user/friend_store.dart';
import 'package:nerimobile/stores/user/user_presence_store.dart';
import 'package:nerimobile/stores/user/user_store.dart';

typedef UserActivity = ({User user, ActivityStatus activity});

final activitiesProvider = Provider<List<UserActivity>>((ref) {
  final presences = ref.watch(presencesProvider);
  final users = ref.watch(usersProvider);
  final blocked = ref.watch(blockedProvider);

  final activities = <UserActivity>[];

  for (final presence in presences.values) {
    final user = users[presence.userId];
    if (user == null || user.bot || blocked.contains(user.id)) continue;

    for (final activity in presence.activities ?? const <ActivityStatus>[]) {
      activities.add((user: user, activity: activity));
    }
  }

  activities.sort(
    (a, b) => (b.activity.startedAt ?? 0).compareTo(a.activity.startedAt ?? 0),
  );

  return activities;
});
