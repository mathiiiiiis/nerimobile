import 'package:dio/dio.dart';
import 'package:nerimobile/models/post.dart';

Future<List<Post>> fetchAnnouncementPosts(Dio dio) async {
  final response = await dio.get('/posts/announcement');
  return _posts(response.data);
}

Future<List<Post>> fetchFeedPosts(
  Dio dio, {
  required int limit,
  String? beforeId,
  String? afterId,
}) async {
  final response = await dio.get(
    '/posts/feed',
    queryParameters: {
      'limit': limit,
      'beforeId': ?beforeId,
      'afterId': ?afterId,
    },
  );
  return _posts(response.data);
}

List<Post> _posts(dynamic data) => (data as List<dynamic>)
    .map((post) => Post.fromJson(post as Map<String, dynamic>))
    .toList();
