import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

class AudioState {
  const AudioState({
    this.url,
    this.playing = false,
    this.position = Duration.zero,
    this.duration,
  });

  final String? url;
  final bool playing;
  final Duration position;
  final Duration? duration;

  bool isCurrent(String other) => url == other;

  AudioState copyWith({
    String? url,
    bool? playing,
    Duration? position,
    Duration? duration,
  }) => AudioState(
    url: url ?? this.url,
    playing: playing ?? this.playing,
    position: position ?? this.position,
    duration: duration ?? this.duration,
  );
}

final audioProvider = NotifierProvider<AudioNotifier, AudioState>(
  AudioNotifier.new,
);

class AudioNotifier extends Notifier<AudioState> {
  Player? _player;

  final _subscriptions = <StreamSubscription<dynamic>>[];
  final _resumeAt = <String, Duration>{};

  @override
  AudioState build() {
    ref.onDispose(_teardown);
    return const AudioState();
  }

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
    final player = _player ??= _create();

    if (state.isCurrent(url)) {
      await (state.playing ? player.pause() : player.play());
      return;
    }

    await player.pause();
    state = AudioState(url: url, position: _resumeAt[url] ?? Duration.zero);

    await player.open(Media(url), play: false);
    if (state.position > Duration.zero) await player.seek(state.position);
    await player.play();
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
