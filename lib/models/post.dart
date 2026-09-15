import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/models/user.dart';

class Post {
  final String id;
  final String? content;
  final User createdBy;
  final int createdAt;
  final int? editedAt;
  final bool deleted;
  final bool blocked;

  final List<Attachment> attachments;
  final List<User> mentions;
  final Embed? embed;

  final String? commentToId;
  final Post? commentTo;
  final Post? repost;
  final List<User> reposts;

  final bool likedByMe;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final int views;

  Post({
    required this.id,
    required this.createdBy,
    required this.createdAt,
    this.content,
    this.editedAt,
    this.deleted = false,
    this.blocked = false,
    this.attachments = const [],
    this.mentions = const [],
    this.embed,
    this.commentToId,
    this.commentTo,
    this.repost,
    this.reposts = const [],
    this.likedByMe = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.repostCount = 0,
    this.views = 0,
  });

  bool get isRepost => repost != null;
  bool get isComment => commentToId != null;

  factory Post.fromJson(Map<String, dynamic> json) {
    final counts = json['_count'] as Map<String, dynamic>? ?? const {};

    return Post(
      id: json['id'],
      content: json['content'] as String?,
      createdBy: User.fromJson(json['createdBy'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as int,
      editedAt: json['editedAt'] as int?,
      deleted: (json['deleted'] ?? false) as bool,
      blocked: (json['block'] ?? false) as bool,
      attachments: _list(json['attachments'], Attachment.fromJson),
      mentions: _list(json['mentions'], User.fromJson),
      embed: json['embed'] != null
          ? Embed.fromJson(json['embed'] as Map<String, dynamic>)
          : null,
      commentToId: json['commentToId'] as String?,
      commentTo: _post(json['commentTo']),
      repost: _post(json['repost']),
      reposts: _reposters(json['reposts']),
      likedByMe: (json['likedBy'] as List?)?.isNotEmpty ?? false,
      likeCount: (counts['likedBy'] ?? 0) as int,
      commentCount: (counts['comments'] ?? 0) as int,
      repostCount: (counts['reposts'] ?? 0) as int,
      views: (json['views'] ?? 0) as int,
    );
  }
}

Post? _post(dynamic json) =>
    json == null ? null : Post.fromJson(json as Map<String, dynamic>);

List<User> _reposters(dynamic json) => [
  for (final item in (json as List?) ?? const [])
    User.fromJson(
      (item as Map<String, dynamic>)['createdBy'] as Map<String, dynamic>,
    ),
];

List<T> _list<T>(dynamic json, T Function(Map<String, dynamic>) parse) => [
  for (final item in (json as List?) ?? const [])
    parse(item as Map<String, dynamic>),
];
