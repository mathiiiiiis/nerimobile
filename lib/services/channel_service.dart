import 'package:dio/dio.dart';
import 'package:nerimobile/models/message.dart';

Future<List<Message>> fetchMessages(Dio dio, String channelId) async {
  final response = await dio.get('/channels/$channelId/messages');
  return (response.data as List<dynamic>)
      .map((m) => Message.fromJson(m as Map<String, dynamic>))
      .toList();
}

Future<Map<String, dynamic>> postMessage(
  Dio dio,
  String channelId,
  String content,
) async {
  final response = await dio.post(
    '/channels/$channelId/messages',
    data: {'content': content},
  );
  return response.data as Map<String, dynamic>;
}
