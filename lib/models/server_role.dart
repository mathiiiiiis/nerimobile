class ServerRole {
  final String id;
  final String serverId;
  final String name;
  final bool hideRole;
  final String? hexColor;
  final int permissions;
  final int order;
  final String? icon;

  ServerRole({
    required this.id,
    required this.serverId,
    required this.name,
    required this.order,
    required this.hideRole,
    required this.permissions,
    this.hexColor,
    this.icon,
  });

  factory ServerRole.fromJson(Map<String, dynamic> json) => ServerRole(
    id: json['id'] as String,
    serverId: json['serverId'] as String,
    name: json['name'] as String,
    order: json['order'] as int,
    hideRole: json['hideRole'] as bool,
    permissions: json['permissions'] as int,
    hexColor: json['hexColor'] as String?,
    icon: json['icon'] as String?,
  );

  ServerRole merge(Map<String, dynamic> updated) => ServerRole(
    id: id,
    serverId: serverId,
    name: updated['name'] ?? name,
    order: updated['order'] ?? order,
    hideRole: updated['hideRole'] ?? hideRole,
    permissions: updated['permissions'] ?? permissions,
    hexColor: updated.containsKey('hexColor') ? updated['hexColor'] : hexColor,
    icon: updated.containsKey('icon') ? updated['icon'] : icon,
  );
}
