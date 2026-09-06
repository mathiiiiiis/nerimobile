import 'package:nerimobile/theme/core/token.dart';

enum PresenceStatus {
  //TODO: add l10n
  offline(0, 'Offline', NeriToken.statusOffline),
  online(1, 'Online', NeriToken.statusOnline),
  lookingToPlay(2, 'Looking To Play', NeriToken.statusLookingToPlay),
  awayFromKeyboard(3, 'Away From Keyboard', NeriToken.statusAwayFromKeyboard),
  doNotDisturb(4, 'Do Not Disturb', NeriToken.statusDoNotDisturb);

  final int value;
  final String name;
  final NeriToken token;
  const PresenceStatus(this.value, this.name, this.token);

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
