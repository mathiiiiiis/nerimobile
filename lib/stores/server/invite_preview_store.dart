import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/server_invite.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/server_service.dart';

final invitePreviewProvider = FutureProvider.family<InvitePreview?, String>((
  ref,
  code,
) async {
  try {
    return await fetchInvitePreview(ref.read(dioProvider), code);
  } on DioException catch (error) {
    if (error.response?.statusCode == 400) return null;
    rethrow;
  }
});
