enum ChannelType {
  dmText(0),
  serverText(1),
  category(2);

  final int value;
  const ChannelType(this.value);

  static ChannelType fromInt(int v) =>
      ChannelType.values.firstWhere((e) => e.value == v);
}

class Channel {
  final String id;
  final int type;
  final String? name;
  final int? order;
  final String? serverId;
  final String? icon;
  final String? categoryId;
  final int? lastMessagedAt;
  final List<ChannelPermission>? permissions;

  Channel({
    required this.id,
    required this.type,
    this.permissions,
    this.name,
    this.serverId,
    this.icon,
    this.order,
    this.categoryId,
    this.lastMessagedAt,
  });

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
    id: json['id'],
    type: json['type'],

    name: json['name'],
    serverId: json['serverId'],
    order: json['order'],
    icon: json['icon'],
    categoryId: json['categoryId'],
    permissions: (json['permissions'] as List?)
        ?.map((e) => ChannelPermission.fromJson(e))
        .toList(),
    lastMessagedAt: json['lastMessagedAt'] as int?,
  );

  Channel copyWith({int? lastMessagedAt}) {
    return Channel(
      id: id,
      type: type,
      name: name,
      serverId: serverId,
      order: order,
      icon: icon,
      categoryId: categoryId,
      permissions: permissions,
      lastMessagedAt: lastMessagedAt ?? this.lastMessagedAt,
    );
  }
}

class ChannelPermission {
  final int permissions;
  final String roleId;
  ChannelPermission({required this.permissions, required this.roleId});

  factory ChannelPermission.fromJson(Map<String, dynamic> json) =>
      ChannelPermission(
        permissions: json['permissions'],
        roleId: json['roleId'],
      );

  Map<String, dynamic> toJson() => {
    'permissions': permissions,
    'roleId': roleId,
  };
}
