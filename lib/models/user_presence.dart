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

class ActivityStatus {
  final String name;
  final String action;
  final String? title;
  final String? subtitle;
  final String? imgSrc;
  final String? link;
  final int? startedAt;
  final int? endsAt;
  final num? speed;

  ActivityStatus({
    required this.name,
    required this.action,
    this.title,
    this.subtitle,
    this.imgSrc,
    this.link,
    this.startedAt,
    this.endsAt,
    this.speed,
  });

  factory ActivityStatus.fromJson(Map<String, dynamic> json) => ActivityStatus(
    name: json['name'],
    action: json['action'],
    title: json['title'],
    subtitle: json['subtitle'],
    imgSrc: json['imgSrc'],
    link: json['link'],
    startedAt: json['startedAt'],
    endsAt: json['endsAt'],
    speed: json['speed'],
  );
}

class UserPresence {
  final String userId;
  final int status;
  final String? custom;
  final List<ActivityStatus>? activities;

  UserPresence({
    required this.userId,
    required this.status,
    this.custom,
    this.activities,
  });

  ActivityStatus? get activity =>
      activities == null || activities!.isEmpty ? null : activities!.first;

  factory UserPresence.fromJson(Map<String, dynamic> json) => UserPresence(
    userId: json['userId'],
    status: json['status'] ?? 0,
    custom: json['custom'],
    activities: _activities(json['activities']),
  );

  //missing fields stay unchanged, null clears them
  UserPresence merge(Map<String, dynamic> json) => UserPresence(
    userId: userId,
    status: json.containsKey('status') ? json['status'] : status,
    custom: json.containsKey('custom') ? json['custom'] : custom,
    activities: json.containsKey('activities')
        ? _activities(json['activities'])
        : activities,
  );

  static List<ActivityStatus>? _activities(dynamic raw) => raw == null
      ? null
      : (raw as List)
            .map((a) => ActivityStatus.fromJson(a as Map<String, dynamic>))
            .toList();
}
