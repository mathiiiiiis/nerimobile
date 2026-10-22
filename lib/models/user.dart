import 'package:nerimobile/models/server.dart';

class User {
  final String id;
  final String username;
  final String tag;
  final String? avatar;
  final String? banner;
  final String hexColor;
  final int badges;
  final bool bot;

  final Profile? profile;
  final Set<String> _unsent;

  User({
    required this.id,
    required this.username,
    required this.hexColor,
    this.tag = '',
    this.avatar,
    this.banner,
    this.badges = 0,
    this.bot = false,
    this.profile,
    Set<String> unsent = const {},
  }) : _unsent = unsent;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    username: (json['username'] ?? 'Unknown') as String,
    tag: (json['tag'] ?? '') as String,
    hexColor: (json['hexColor'] ?? '#fff') as String,
    avatar: json['avatar'] as String?,
    banner: json['banner'] as String?,
    badges: (json['badges'] ?? 0) as int,
    bot: (json['bot'] ?? false) as bool,
    profile: json['profile'] != null ? Profile.fromJson(json['profile']) : null,
    unsent: {
      for (final key in _partialKeys)
        if (!json.containsKey(key)) key,
    },
  );

  static const _partialKeys = ['banner', 'profile'];

  User filledFrom(User known) => User(
    id: id,
    username: username,
    tag: tag,
    hexColor: hexColor,
    avatar: avatar,
    banner: _unsent.contains('banner') ? known.banner : banner,
    badges: badges,
    bot: bot,
    profile: _unsent.contains('profile') ? known.profile : profile,
    unsent: _unsent.intersection(known._unsent),
  );
}

class Profile {
  final ServerClan? clan;
  final int? font;

  Profile({this.clan, this.font});

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    clan: json['clan'] != null ? ServerClan.fromJson(json['clan']) : null,
    font: json['font'] as int?,
  );
}
