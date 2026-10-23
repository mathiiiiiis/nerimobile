import 'package:nerimobile/models/post.dart';
import 'package:nerimobile/models/user.dart';

class UserDetails {
  final User user;
  final int joinedAt;

  final String? bio;
  final String? bgColorOne;
  final String? bgColorTwo;
  final String? primaryColor;

  final int followerCount;
  final int followingCount;
  final int likeCount;
  final int postCount;
  final bool hideFollowers;
  final bool hideFollowing;

  final bool following;
  final bool followsYou;
  final bool blocked;

  final List<String> mutualFriendIds;
  final List<String> mutualServerIds;
  final Post? latestPost;
  final int? suspensionExpiresAt;

  UserDetails({
    required this.user,
    required this.joinedAt,
    this.bio,
    this.bgColorOne,
    this.bgColorTwo,
    this.primaryColor,
    this.followerCount = 0,
    this.followingCount = 0,
    this.likeCount = 0,
    this.postCount = 0,
    this.hideFollowers = false,
    this.hideFollowing = false,
    this.following = false,
    this.followsYou = false,
    this.blocked = false,
    this.mutualFriendIds = const [],
    this.mutualServerIds = const [],
    this.latestPost,
    this.suspensionExpiresAt,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final profile = json['profile'] as Map<String, dynamic>?;
    final counts = json['_count'] as Map<String, dynamic>? ?? const {};

    return UserDetails(
      user: User.fromJson({...user, 'profile': profile}),
      joinedAt: user['joinedAt'] as int,
      bio: profile?['bio'] as String?,
      bgColorOne: profile?['bgColorOne'] as String?,
      bgColorTwo: profile?['bgColorTwo'] as String?,
      primaryColor: profile?['primaryColor'] as String?,
      followerCount: (counts['followers'] ?? 0) as int,
      followingCount: (counts['following'] ?? 0) as int,
      likeCount: (counts['likedPosts'] ?? 0) as int,
      postCount: (counts['posts'] ?? 0) as int,
      hideFollowers: (json['hideFollowers'] ?? false) as bool,
      hideFollowing: (json['hideFollowing'] ?? false) as bool,
      following: (user['followers'] as List?)?.isNotEmpty ?? false,
      followsYou: (user['followsYou'] ?? false) as bool,
      blocked: (json['block'] ?? false) as bool,
      mutualFriendIds: _ids(json['mutualFriendIds']),
      mutualServerIds: _ids(json['mutualServerIds']),
      latestPost: json['latestPost'] != null
          ? Post.fromJson(json['latestPost'] as Map<String, dynamic>)
          : null,
      suspensionExpiresAt: json['suspensionExpiresAt'] as int?,
    );
  }
}

List<String> _ids(dynamic json) => [
  for (final id in (json as List?) ?? const []) id as String,
];
