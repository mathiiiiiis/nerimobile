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
    this.fullscreen = false,
  });

  final String? url;
  final bool playing;
  final Duration position;
  final Duration? duration;
  final bool muted;
  final bool fullscreen;

  bool isCurrent(String other) => url == other;

  MediaState copyWith({
    String? url,
    bool? playing,
    Duration? position,
    Duration? duration,
    bool? muted,
    bool? fullscreen,
  }) => MediaState(
    url: url ?? this.url,
    playing: playing ?? this.playing,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    muted: muted ?? this.muted,
    fullscreen: fullscreen ?? this.fullscreen,
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
        state = const MediaState();
        unawaited(_release());
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

    final resume = state.position;
    await player.open(Media(url));
    if (resume > Duration.zero) await player.seek(resume);
  }

  Future<void> setMuted(bool muted) async {
    state = state.copyWith(muted: muted);
    await _player?.setVolume(muted ? 0 : 100);
  }

  void setFullscreen(bool fullscreen) =>
      state = state.copyWith(fullscreen: fullscreen);

  Future<void> seek(String url, Duration position) async {
    if (!state.isCurrent(url)) return;
    _resumeAt[url] = position;
    await _player?.seek(position);
  }

  Future<void> _release() async {
    final player = _player;
    _player = null;
    _video = null;
    _subscriptions
      ..forEach((subscriptions) => subscriptions.cancel())
      ..clear();
    await player?.dispose();
  }

  void _teardown() {
    unawaited(_release());
  }
}
