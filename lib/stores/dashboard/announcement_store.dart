import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/db/daos/announcement_dao.dart';
import 'package:nerimobile/db/database.dart';
import 'package:nerimobile/models/post.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/post_service.dart';

final announcementsProvider =
    AsyncNotifierProvider<AnnouncementNotifier, List<Post>>(
      AnnouncementNotifier.new,
    );

class AnnouncementNotifier extends AsyncNotifier<List<Post>> {
  AnnouncementDao get _dao => AnnouncementDao(ref.read(databaseProvider));

  @override
  Future<List<Post>> build() async {
    final cached = await _visible(await _dao.all());
    if (cached.isNotEmpty) state = AsyncData(cached);

    unawaited(refresh());

    return cached;
  }

  Future<void> refresh() async {
    final List<Map<String, dynamic>> payloads;
    try {
      payloads = await fetchAnnouncementPayloads(ref.read(dioProvider));
    } catch (_) {
      return;
    }

    await _dao.sync(payloads);
    state = AsyncData(await _visible(payloads.map(Post.fromJson).toList()));
  }

  Future<void> dismiss(String id) async {
    await _dao.dismiss(id);
    state = AsyncData([
      for (final post in state.value ?? const <Post>[])
        if (post.id != id) post,
    ]);
  }

  Future<List<Post>> _visible(List<Post> posts) async {
    final dismissed = await _dao.dismissed();

    return [
      for (final post in posts)
        if (!dismissed.contains(post.id)) post,
    ];
  }
}
