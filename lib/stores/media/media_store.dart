import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaState {
  const MediaState({
    this.url,
    this.playing = false,
    this.position = Duration.zero,
    this.duration,
    this.muted = false,
  });

  final String? url;
  final bool playing;
  final Duration position;
  final Duration? duration;
  final bool muted;

  bool isCurrent(String other) => url == other;

  MediaState copyWith({
    String? url,
    bool? playing,
    Duration? position,
    Duration? duration,
    bool? muted,
  }) => MediaState(
    url: url ?? this.url,
    playing: playing ?? this.playing,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    muted: muted ?? this.muted,
  );
}

final mediaProvider = NotifierProvider<MediaNotifier, MediaState>(
  MediaNotifier.new,
);

class MediaNotifier extends Notifier<MediaState> {
  Player? _player;
  VideoController? _video;

  final _subscriptions = <StreamSubscription<dynamic>>[];
  final _resumeAt = <String, Duration>{};

  @override
  MediaState build() {
    ref.onDispose(_teardown);
    return const MediaState();
  }

  VideoController get video => _video ??= VideoController(_ensurePlayer());
  Player _ensurePlayer() => _player ??= _create();

  Player _create() {
    final player = Player();
    _subscriptions.addAll([
      player.stream.playing.listen((playing) {
        state = state.copyWith(playing: playing);
      }),
      player.stream.position.listen((position) {
        state = state.copyWith(position: position);
        final url = state.url;
        if (url != null) _resumeAt[url] = position;
      }),
      player.stream.duration.listen((duration) {
        if (duration > Duration.zero) {
          state = state.copyWith(duration: duration);
        }
      }),
      player.stream.completed.listen((completed) {
        if (!completed) return;
        final url = state.url;
        if (url != null) _resumeAt.remove(url);
        state = state.copyWith(playing: false, position: Duration.zero);
      }),
    ]);
    return player;
  }

  Future<void> toggle(String url) async {
    final player = _ensurePlayer();

    if (state.isCurrent(url)) {
      await (state.playing ? player.pause() : player.play());
      return;
    }

    await player.pause();
    state = MediaState(url: url, position: _resumeAt[url] ?? Duration.zero);

    await player.open(Media(url), play: false);
    if (state.position > Duration.zero) await player.seek(state.position);
    await player.play();
  }

  Future<void> setMuted(bool muted) async {
    state = state.copyWith(muted: muted);
    await _player?.setVolume(muted ? 0 : 100);
  }

  Future<void> seek(String url, Duration position) async {
    if (!state.isCurrent(url)) return;
    _resumeAt[url] = position;
    await _player?.seek(position);
  }

  void _teardown() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _player?.dispose();
  }
}
