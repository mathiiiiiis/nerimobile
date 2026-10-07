class Server {
  final String id;
  final String name;
  final String? avatar;
  final String defaultChannelId;
  final String defaultRoleId;
  final String hexColor;
  final String createdById;

  Server({
    required this.id,
    required this.name,
    required this.hexColor,
    required this.defaultChannelId,
    required this.defaultRoleId,
    required this.createdById,
    this.avatar,
  });

  factory Server.fromJson(Map<String, dynamic> json) => Server(
    id: json['id'],
    name: json['name'],
    hexColor: json['hexColor'],
    avatar: json['avatar'],
    defaultChannelId: json['defaultChannelId'],
    defaultRoleId: json['defaultRoleId'],
    createdById: json['createdById'],
  );

  //avatar can be cleared to null
  Server merge(Map<String, dynamic> updated) => Server(
    id: id,
    name: updated['name'] ?? name,
    hexColor: hexColor,
    avatar: updated.containsKey('avatar') ? updated['avatar'] : avatar,
    defaultChannelId: updated['defaultChannelId'] ?? defaultChannelId,
    defaultRoleId: defaultRoleId,
    createdById: updated['createdById'] ?? createdById,
  );
}

class ServerClan {
  final String serverId;
  final String icon;
  final String tag;

  ServerClan({required this.serverId, required this.icon, required this.tag});

  factory ServerClan.fromJson(Map<String, dynamic> json) => ServerClan(
    serverId: json['serverId'],
    icon: json['icon'],
    tag: json['tag'],
  );
}
