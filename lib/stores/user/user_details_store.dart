import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/user_details.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/user_service.dart';
import 'package:nerimobile/stores/user/user_store.dart';

const _keepFor = Duration(minutes: 5);

final userDetailsProvider = FutureProvider.autoDispose
    .family<UserDetails?, String>((ref, userId) async {
      final link = ref.keepAlive();
      Timer? release;
      ref.onCancel(() => release = Timer(_keepFor, link.close));
      ref.onResume(() => release?.cancel());
      ref.onDispose(() => release?.cancel());

      try {
        final details = await fetchUserDetails(ref.read(dioProvider), userId);
        ref.read(usersProvider.notifier).addUser(details.user);
        return details;
      } on DioException catch (error) {
        if (error.response?.statusCode == 400) return null;
        rethrow;
      }
    });
