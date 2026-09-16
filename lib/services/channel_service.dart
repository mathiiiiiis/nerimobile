import 'package:dio/dio.dart';
import 'package:nerimobile/models/message.dart';

Future<List<Message>> fetchMessages(
  Dio dio,
  String channelId, {
  required int limit,
  String? before,
  String? after,
}) async {
  final response = await dio.get(
    '/channels/$channelId/messages',
    queryParameters: {'limit': limit, 'before': ?before, 'after': ?after},
  );
  return (response.data as List<dynamic>)
      .map((m) => Message.fromJson(m as Map<String, dynamic>))
      .toList();
}

Future<Map<String, dynamic>> postMessage(
  Dio dio,
  String channelId,
  String content, {
  List<String> replyToMessageIds = const [],
  bool mentionReplies = false,
}) async {
  final response = await dio.post(
    '/channels/$channelId/messages',
    data: {
      'content': content,
      if (replyToMessageIds.isNotEmpty) ...{
        'replyToMessageIds': replyToMessageIds,
        'mentionReplies': mentionReplies,
      },
    },
  );
  return response.data as Map<String, dynamic>;
}

Future<Map<String, dynamic>> patchMessage(
  Dio dio,
  String channelId,
  String messageId,
  String content,
) async {
  final response = await dio.patch(
    '/channels/$channelId/messages/$messageId',
    data: {'content': content},
  );
  return response.data as Map<String, dynamic>;
}

Future<void> deleteMessage(Dio dio, String channelId, String messageId) =>
    dio.delete('/channels/$channelId/messages/$messageId');
