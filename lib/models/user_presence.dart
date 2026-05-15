import 'package:flutter/services.dart';
import 'package:nerimobile/theme/app_theme.dart';

enum PresenceStatus {
  offline(0, 'Offline', AppTheme.disabledColor),
  online(1, 'Online', AppTheme.successColor),
  lookingToPlay(2, 'Looking To Play', AppTheme.primaryColor),
  awayFromKeyboard(3, 'Away From Keyboard', AppTheme.warnColor),
  doNotDisturb(4, 'Do Not Disturb', AppTheme.alertColor);

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
