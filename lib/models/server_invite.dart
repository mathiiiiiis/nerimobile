import 'package:nerimobile/models/server.dart';
import 'package:nerimobile/models/user.dart';

class ServerInvite {
  final String code;
  final bool isCustom;
  final int uses;
  final String serverId;
  final String createdById;
  final int createdAt;
  //only invite list includes creator
  final User? createdBy;

  ServerInvite({
    required this.code,
    required this.isCustom,
    required this.uses,
    required this.serverId,
    required this.createdById,
    required this.createdAt,
    this.createdBy,
  });

  factory ServerInvite.fromJson(Map<String, dynamic> json) => ServerInvite(
    code: json['code'] as String,
    isCustom: (json['isCustom'] ?? false) as bool,
    uses: (json['uses'] ?? 0) as int,
    serverId: json['serverId'] as String,
    createdById: json['createdById'] as String,
    createdAt: json['createdAt'] as int,
    createdBy: json['createdBy'] != null
        ? User.fromJson(json['createdBy'])
        : null,
  );
}

typedef InvitePreview = ({Server server, int memberCount});

InvitePreview invitePreviewFromJson(Map<String, dynamic> json) =>
    (server: Server.fromJson(json), memberCount: json['memberCount'] as int);
