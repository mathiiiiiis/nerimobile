import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/post.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/post_service.dart';
import 'package:nerimobile/stores/auth/auth_store.dart';

const feedPageSize = 30;

@immutable
class Feed {
  const Feed({
    this.posts = const [],
    this.loaded = false,
    this.loading = false,
    this.hasMore = true,
  });

  final List<Post> posts;
  final bool loaded;
  final bool loading;
  final bool hasMore;

  Post? get oldest => posts.isEmpty ? null : posts.last;

  Feed copyWith({
    List<Post>? posts,
    bool? loaded,
    bool? loading,
    bool? hasMore,
  }) => Feed(
    posts: posts ?? this.posts,
    loaded: loaded ?? this.loaded,
    loading: loading ?? this.loading,
    hasMore: hasMore ?? this.hasMore,
  );
}

final feedProvider = NotifierProvider<FeedNotifier, Feed>(FeedNotifier.new);

class FeedNotifier extends Notifier<Feed> {
  @override
  Feed build() {
    final token = ref.watch(authProvider).value;
    if (token == null) return const Feed();

    unawaited(refresh());

    return const Feed();
  }

  Future<void> refresh() async {
    final batch = await _fetch();
    if (batch == null) return;

    state = Feed(
      posts: _deduped(batch),
      loaded: true,
      hasMore: batch.length == feedPageSize,
    );
  }

  Future<void> loadMore() async {
    final oldest = state.oldest;
    if (state.loading || !state.hasMore || oldest == null) return;
    state = state.copyWith(loading: true);

    final batch = await _fetch(olderThan: oldest.id);
    state = state.copyWith(
      posts: batch == null ? state.posts : _deduped([...state.posts, ...batch]),
      loading: false,
      hasMore: batch == null ? state.hasMore : batch.length == feedPageSize,
    );
  }

  Future<List<Post>?> _fetch({String? olderThan}) async {
    try {
      return await fetchFeedPosts(
        ref.read(dioProvider),
        limit: feedPageSize,
        afterId: olderThan,
      );
    } catch (e) {
      debugPrint('fetchFeedPosts failed: $e');
      return null;
    }
  }
}

List<Post> _deduped(List<Post> posts) {
  final seen = <String>{};
  final reposted = <String>{};

  return [
    for (final post in posts)
      if (seen.add(post.id) &&
          (post.repost == null || reposted.add(post.repost!.id)))
        post,
  ];
}
