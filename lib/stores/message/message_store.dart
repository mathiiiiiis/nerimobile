import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/channel_service.dart';

final messageProvidier =
    NotifierProvider<MessagesNotifier, Map<String, List<Message>>>(
      MessagesNotifier.new,
    );

class MessagesNotifier extends Notifier<Map<String, List<Message>>> {
  @override
  Map<String, List<Message>> build() => const {};

  Future<void> loadMessages(String channelId) async {
    if (state[channelId] != null) return;
    try {
      state = {
        ...state,
        channelId: await fetchMessages(ref.read(dioProvider), channelId),
      };
    } on DioException catch (e) {
      debugPrint(
        'loadMessages error: ${e.response?.statusCode} ${e.response?.data}',
      );
    }
  }

  void setMessages(String channelId, List<Message> list) =>
      state = {...state, channelId: list};

  void addMessage(String channelId, Message message) {
    final current = state[channelId];
    if (current == null) return;
    final updated = [...current, message];
    state = {
      ...state,
      channelId: updated.length > 100
          ? updated.sublist(updated.length - 100)
          : updated,
    };
  }

  void updateMessage(
    String channelId,
    String messageId,
    Map<String, dynamic> partial,
  ) {
    final current = state[channelId];
    if (current == null) return;
    final index = current.indexWhere((m) => m.id == messageId);
    if (index == -1) return;
    final updated = List<Message>.from(current);
    updated[index] = current[index].copyWith(partial);
    state = {...state, channelId: updated};
  }

  void removeMessage(String channelId, String messageId) {
    final current = state[channelId];
    if (current == null) return;
    state = {
      ...state,
      channelId: current.where((m) => m.id != messageId).toList(),
    };
  }
}
