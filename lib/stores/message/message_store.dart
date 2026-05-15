import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nerimobile/services/channel_service.dart';
import 'package:signals/signals_flutter.dart';
import '../../models/message.dart';

final messageStore = MessageStore();

class MessageStore {
  final messages = mapSignal<String, List<Message>>({});

  Future<void> loadMessages(String channelId) async {
    if (messages[channelId] != null) return;
    try {
      final response = await fetchMessages(channelId);

      messages[channelId] = response;
    } on DioException catch (e) {
      debugPrint(
        'loadMessages error: ${e.response?.statusCode} ${e.response?.data}',
      );
    }
  }

  void setMessages(String channelId, List<Message> list) {
    messages[channelId] = list;
  }

  void addMessage(String channelId, Message message) {
    final current = messages[channelId];
    if (current == null) return;
    final updated = [...current, message];
    messages[channelId] = updated.length > 100
        ? updated.sublist(updated.length - 100)
        : updated;
  }

  void updateMessage(
    String channelId,
    String messageId,
    Map<String, dynamic> partial,
  ) {
    final current = messages[channelId];
    if (current == null) return;
    final index = current.indexWhere((m) => m.id == messageId);
    if (index == -1) return;
    final updated = List<Message>.from(current);
    updated[index] = current[index].copyWith(partial);
    messages[channelId] = updated;
  }

  void removeMessage(String channelId, String messageId) {
    final current = messages[channelId];
    if (current == null) return;
    messages[channelId] = current.where((m) => m.id != messageId).toList();
  }
}
