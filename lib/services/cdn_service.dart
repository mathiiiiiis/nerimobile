import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

Future<String> fetchCdnToken(Dio dio, String channelId) async {
  final response = await dio.post('/channels/$channelId/cdn/token');
  return (response.data as Map<String, dynamic>)['token'] as String;
}

Future<String> uploadFile(
  Dio cdnDio, {
  required String channelId,
  required String token,
  required String path,
  CancelToken? cancelToken,
  ValueChanged<double>? onProgress,
}) async {
  final form = FormData.fromMap({
    'f': await MultipartFile.fromFile(
      path,
      filename: p.basename(path),
      contentType: DioMediaType.parse(
        lookupMimeType(path) ?? 'application/octet-stream',
      ),
    ),
  });

  final response = await cdnDio.post(
    'attachments/$channelId',
    data: form,
    options: Options(headers: {'Authorization': token}),
    cancelToken: cancelToken,
    onSendProgress: (sent, total) =>
        onProgress?.call(total <= 0 ? 0 : sent / total),
  );

  return (response.data as Map<String, dynamic>)['fieldId'] as String;
}
