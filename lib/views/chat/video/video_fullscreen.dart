import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:nerimobile/stores/media/media_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/format.dart';

const _open = Duration(milliseconds: 200);
const _trackHeight = 4.0;
const _buttonOpacity = 0.4;
const _dismissDistance = 120.0;
const _dismissVelocity = 700.9;

Future<void> openVideoFullscreen(BuildContext context, String url) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: _open,
      reverseTransitionDuration: _open,
      pageBuilder: (_, _, _) => VideoFullscreen(url: url),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class VideoFullscreen extends ConsumerStatefulWidget {
  const VideoFullscreen({super.key, required this.url});

  final String url;

  @override
  ConsumerState<VideoFullscreen> createState() => _VideoFullscreenState();
}

class _VideoFullscreenState extends ConsumerState<VideoFullscreen> {
  late final MediaNotifier _media;

  bool _controls = true;
  double _drag = 0;

  @override
  void initState() {
    super.initState();
    _media = ref.read(mediaProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _media.setFullscreen(true);
    });
  }

  @override
  void dispose() {
    Future(_media.stop);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _controls = !_controls);
    SystemChrome.setEnabledSystemUIMode(
      _controls ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() => _drag = (_drag + details.primaryDelta!).clamp(0.0, 4000.0));
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_drag > _dismissDistance || velocity > _dismissVelocity) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _drag = 0);
  }

  @override
  Widget build(BuildContext context) {
    final media = ref.watch(mediaProvider);
    final opacity = (1 - _drag / (_dismissDistance * 3)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: opacity),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: Transform.translate(
          offset: Offset(0, _drag),
          child: Stack(
            children: [
              Center(
                child: Video(
                  controller: _media.video,
                  controls: null,
                  fill: Colors.transparent,
                  fit: BoxFit.contain,
                ),
              ),
              _Controls(
                visible: _controls,
                media: media,
                notifier: _media,
                url: widget.url,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.visible,
    required this.media,
    required this.notifier,
    required this.url,
  });

  final bool visible;
  final MediaState media;
  final MediaNotifier notifier;
  final String url;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return IgnorePointer(
      ignoring: !visible,
      child: Opacity(
        opacity: visible ? 1 : 0,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                sizing.space(NeriSpacingRole.md),
                sizing.space(NeriSpacingRole.md) +
                    MediaQuery.viewPaddingOf(context).top,
                sizing.space(NeriSpacingRole.md),
                sizing.space(NeriSpacingRole.md),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: ControlButton(
                  icon: Symbols.close_rounded,
                  size: sizing.dimen(NeriDimen.avatarSm),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            //TODO: message options once context menu exists
            Align(
              alignment: Alignment.bottomCenter,
              child: _BottomBar(media: media, notifier: notifier, url: url),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.media,
    required this.notifier,
    required this.url,
  });

  final MediaState media;
  final MediaNotifier notifier;
  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final total = media.duration ?? Duration.zero;
    final radius = Radius.circular(sizing.radius(NeriRadiusRole.xl));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: sizing.space(NeriSpacingRole.md),
            bottom: sizing.space(NeriSpacingRole.md),
          ),
          child: ControlButton(
            icon: media.muted
                ? Symbols.volume_off_rounded
                : Symbols.volume_up_rounded,
            size: sizing.dimen(NeriDimen.avatarSm),
            onTap: () => notifier.setMuted(!media.muted),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors[NeriToken.background],
            borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
            border: Border(
              top: BorderSide(
                color: colors[NeriToken.border],
                width: sizing.border(NeriBorderRole.hairline),
              ),
              left: BorderSide(
                color: colors[NeriToken.border],
                width: sizing.border(NeriBorderRole.hairline),
              ),
              right: BorderSide(
                color: colors[NeriToken.border],
                width: sizing.border(NeriBorderRole.hairline),
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              sizing.space(NeriSpacingRole.md),
              sizing.space(NeriSpacingRole.md),
              sizing.space(NeriSpacingRole.md),
              sizing.space(NeriSpacingRole.md) +
                  MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: Row(
              spacing: sizing.space(NeriSpacingRole.md),
              children: [
                ControlButton(
                  icon: media.playing
                      ? Symbols.pause_rounded
                      : Symbols.play_arrow_rounded,
                  size: sizing.dimen(NeriDimen.controlSize),
                  background: false,
                  onTap: () => notifier.toggle(url),
                ),
                Text(
                  formatDuration(media.position),
                  style: context.neriText[NeriTextRole.labelSmall].copyWith(
                    color: colors[NeriToken.text],
                  ),
                ),
                Expanded(
                  child: _Scrubber(
                    position: media.position,
                    total: total,
                    onSeek: (value) => notifier.seek(url, total * value),
                  ),
                ),
                Text(
                  formatDuration(total),
                  style: context.neriText[NeriTextRole.labelSmall].copyWith(
                    color: colors[NeriToken.text],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ControlButton extends StatelessWidget {
  const ControlButton({
    super.key,
    required this.icon,
    required this.size,
    required this.onTap,
    this.background = true,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final bool background;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background
              ? colors[NeriToken.scrim].withValues(alpha: _buttonOpacity)
              : null,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          fill: 1,
          size: size * 0.55,
          color: colors[NeriToken.text],
        ),
      ),
    );
  }
}

class _Scrubber extends StatelessWidget {
  const _Scrubber({
    required this.position,
    required this.total,
    required this.onSeek,
  });

  final Duration position;
  final Duration total;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final progress = total > Duration.zero
        ? (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) =>
            onSeek(details.localPosition.dx / constraints.maxWidth),
        onHorizontalDragUpdate: (details) => onSeek(
          (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0),
        ),
        child: SizedBox(
          height: _trackHeight * 4,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: _trackHeight,
                decoration: BoxDecoration(
                  color: colors[NeriToken.textTertiary],
                  borderRadius: BorderRadius.circular(_trackHeight / 2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: _trackHeight,
                  decoration: BoxDecoration(
                    color: colors[NeriToken.primary],
                    borderRadius: BorderRadius.circular(_trackHeight / 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
