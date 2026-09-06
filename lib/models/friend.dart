import 'package:nerimobile/models/user.dart';

enum FriendStatus {
  pending(0),
  sent(1),
  friends(2),
  blocked(3);

  final int value;
  const FriendStatus(this.value);

  static FriendStatus fromInt(int v) =>
      FriendStatus.values.firstWhere((e) => e.value == v);
}

class Friend {
  final String id;
  final int status;
  final String userId;
  final String recipientId;
  final User recipient;
  final int createdAt;

  Friend({
    required this.id,
    required this.status,
    required this.userId,
    required this.recipientId,
    required this.recipient,
    required this.createdAt,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
    id: json['id'],
    status: json['status'],
    userId: json['userId'],
    recipientId: json['recipientId'],
    recipient: User.fromJson(json['recipient']),
    createdAt: json['createdAt'],
  );
}
