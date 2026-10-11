import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/channel_service.dart';

final channelNoticeProvider = FutureProvider.family<String?, String>(
  (ref, channelId) => fetchChannelNotice(ref.read(dioProvider), channelId),
);
