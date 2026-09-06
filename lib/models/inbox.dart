import 'package:nerimobile/models/user.dart';

class Inbox {
  final String id;
  final String channelId;
  final String recipientId;
  final User recipient;
  final int? lastSeen;
  final int createdAt;

  Inbox({
    required this.id,
    required this.channelId,
    required this.recipientId,
    required this.recipient,
    required this.createdAt,
    this.lastSeen,
  });

  factory Inbox.fromJson(Map<String, dynamic> json) => Inbox(
    id: json['id'],
    channelId: json['channelId'],
    recipientId: json['recipientId'],
    recipient: User.fromJson(json['recipient']),
    lastSeen: json['lastSeen'],
    createdAt: json['createdAt'],
  );
}
