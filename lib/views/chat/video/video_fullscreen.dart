import 'package:flutter/material.dart';
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
import 'package:nerimobile/views/chat/fullscreen/fullscreen_shell.dart';

const _trackHeight = 4.0;

Future<void> openVideoFullscreen(
  BuildContext context,
  String url, {
  OptionsCallback? onOptions,
}) => openFullscreen(
  context,
  (_) => VideoFullscreen(url: url, onOptions: onOptions),
);

class VideoFullscreen extends ConsumerStatefulWidget {
  const VideoFullscreen({super.key, required this.url, this.onOptions});

  final String url;
  final OptionsCallback? onOptions;

  @override
  ConsumerState<VideoFullscreen> createState() => _VideoFullscreenState();
}

class _VideoFullscreenState extends ConsumerState<VideoFullscreen> {
  late final MediaNotifier _media;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = ref.watch(mediaProvider);
    final onOptions = widget.onOptions;

    return FullscreenShell(
      onOptions: onOptions == null
          ? null
          : () => onOptions(context, ref, widget.url),
      bottom: _BottomBar(media: media, notifier: _media, url: widget.url),
      child: Video(
        controller: _media.video,
        controls: null,
        fill: Colors.transparent,
        fit: BoxFit.contain,
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
