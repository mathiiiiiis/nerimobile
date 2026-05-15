import 'package:flutter/services.dart';

enum PresenceStatus {
  offline(0, 'Offline', Color(0xffadadad)),
  online(1, 'Online', Color(0xff78e380)),
  lookingToPlay(2, 'Looking To Play', Color(0xff4c93ff)),
  awayFromKeyboard(3, 'Away From Keyboard', Color(0xffff8f2c)),
  doNotDisturb(4, 'Do Not Disturb', Color(0xffeb6e6e));

  final int value;
  final String name;
  final Color color;
  const PresenceStatus(this.value, this.name, this.color);

  static final _byValue = {for (final s in PresenceStatus.values) s.value: s};
  static PresenceStatus? fromValue(int value) => _byValue[value];
}

class UserPresence {
  final String userId;
  int status;

  UserPresence({required this.userId, required this.status});

  factory UserPresence.fromJson(Map<String, dynamic> json) =>
      UserPresence(userId: json['userId'], status: json['status']);
}
