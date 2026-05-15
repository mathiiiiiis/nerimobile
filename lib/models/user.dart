import 'package:nerimobile/models/server.dart';

class User {
  final String id;
  final String username;
  final String? avatar;
  final String hexColor;

  final Profile? profile;

  User({
    required this.id,
    required this.username,
    required this.hexColor,
    this.avatar,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    username: (json['username'] ?? 'Unknown') as String,
    hexColor: (json['hexColor'] ?? '#fff') as String,
    avatar: json['avatar'] as String?,

    profile: json['profile'] != null ? Profile.fromJson(json['profile']) : null,
  );
}

class Profile {
  final ServerClan? clan;

  Profile({this.clan});

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    clan: json['clan'] != null ? ServerClan.fromJson(json['clan']) : null,
  );
}
