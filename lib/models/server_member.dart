class ServerMember {
  final String id;
  final String userId;
  final String serverId;
  final String? nickname;
  final Set<String> roleIds;
  final int? muteExpireAt;

  ServerMember({
    required this.id,
    required this.userId,
    required this.serverId,
    required this.roleIds,
    this.nickname,
    this.muteExpireAt,
  });

  bool get isMuted =>
      muteExpireAt != null &&
      muteExpireAt! > DateTime.now().millisecondsSinceEpoch;

  factory ServerMember.fromJson(Map<String, dynamic> json) => ServerMember(
    id: json['id'] as String,
    userId: json['userId'] as String,
    serverId: json['serverId'] as String,
    roleIds: Set<String>.from(json['roleIds'] as List),
    nickname: json['nickname'] as String?,
    muteExpireAt: json['muteExpireAt'] as int?,
  );
}
