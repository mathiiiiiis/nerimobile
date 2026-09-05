import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/config.dart';
import 'package:nerimobile/stores/auth/auth_store.dart';
import 'package:nerimobile/utils/secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(baseUrl: apiUrl, headers: {'Content-Type': 'application/json'}),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) options.headers['Authorization'] = token;
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          ref.read(authProvider.notifier).signOut();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});
