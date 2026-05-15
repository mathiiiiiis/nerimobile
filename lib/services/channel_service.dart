import 'package:dio/dio.dart';
import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/utils/secure_storage.dart';

import 'api_client.dart';

Future<List<Message>> fetchMessages(String channelId) async {
  final token = await getToken();
  final response = await dio.get(
    '/channels/$channelId/messages',
    options: Options(headers: {"Authorization": token}),
  );
  return (response.data as List<dynamic>)
      .map((m) => Message.fromJson(m as Map<String, dynamic>))
      .toList();
}

Future<Map<String, dynamic>> postMessage(
  String channelId,
  String content,
) async {
  final token = await getToken();

  final response = await dio.post(
    '/channels/$channelId/messages',
    data: {'content': content},
    options: Options(headers: {"Authorization": token}),
  );
  return response.data as Map<String, dynamic>;
}
