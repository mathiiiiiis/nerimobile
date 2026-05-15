import 'package:flutter/material.dart';
import 'package:nerimobile/models/user_presence.dart';
import 'package:nerimobile/stores/user_presence_store.dart';

class UserPresence extends StatelessWidget {
  final String userId;
  final bool? showOffline;
  const UserPresence({super.key, required this.userId, this.showOffline});

  @override
  Widget build(BuildContext context) {
    final presence = userPresenceStore.presences[userId];

    final status =
        PresenceStatus.fromValue(presence?.status ?? 0) ??
        PresenceStatus.offline;

    final statusName = status.name;
    final color = status.color;

    if (showOffline == false && status == PresenceStatus.offline) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Text(statusName, style: const TextStyle(fontSize: 12, height: 1)),
      ],
    );
  }
}
