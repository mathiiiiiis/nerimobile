import 'package:nerimobile/models/user.dart';

enum FriendStatus {
  sent(0),
  pending(1),
  friends(2),
  blocked(3);

  final int value;
  const FriendStatus(this.value);

  static FriendStatus fromInt(int v) =>
      FriendStatus.values.firstWhere((e) => e.value == v);
}

class Friend {
  final String id;
  final FriendStatus status;
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

  Friend copyWith({FriendStatus? status}) => Friend(
    id: id,
    status: status ?? this.status,
    userId: userId,
    recipientId: recipientId,
    recipient: recipient,
    createdAt: createdAt,
  );

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
    id: json['id'],
    status: FriendStatus.fromInt(json['status'] as int),
    userId: json['userId'],
    recipientId: json['recipientId'],
    recipient: User.fromJson(json['recipient']),
    createdAt: json['createdAt'],
  );
}
