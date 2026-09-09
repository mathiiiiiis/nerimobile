import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/stores/media/media_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/utils/image.dart';
import 'package:nerimobile/views/chat/video/video_fullscreen.dart';

const _maxWidth = 600.0;
const _maxHeight = 350.0;
const _fallbackRatio = 16 / 9;
const _fade = Duration(milliseconds: 200);
const _scrimOpacity = 0.35;

class VideoPlayer extends ConsumerWidget {
  const VideoPlayer({super.key, required this.attachment});

  final Attachment attachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = attachment.path;
    if (path == null) return const SizedBox.shrink();

    final sizing = context.neriSize;
    final url = buildImageUrl(path);
    final media = ref.watch(mediaProvider);
    final current = media.isCurrent(url) && !media.fullscreen;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.clamp(0.0, _maxWidth);
        final size = constrainDimensions(
          width: attachment.width?.toDouble() ?? available,
          height: attachment.height?.toDouble() ?? available / _fallbackRatio,
          maxWidth: available,
          maxHeight: _maxHeight,
        );

        return ClipRRect(
          borderRadius: sizing.rounded(NeriRadiusRole.image),
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (current)
                  Video(
                    controller: ref.read(mediaProvider.notifier).video,
                    controls: null,
                    fill: Colors.black,
                    fit: BoxFit.contain,
                  )
                else
                  Image.network(
                    buildImageUrl('$path/thumb.webp'),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        ColoredBox(color: context.neri[NeriToken.card]),
                  ),
                if (current)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => openVideoFullscreen(context, url),
                  ),
                _PlayOverlay(
                  visible: !current || !media.playing,
                  onTap: () => ref.read(mediaProvider.notifier).toggle(url),
                ),
                if (current)
                  Positioned(
                    left: sizing.space(NeriSpacingRole.sm),
                    bottom: sizing.space(NeriSpacingRole.sm),
                    child: _MuteButton(
                      muted: media.muted,
                      onTap: () => ref
                          .read(mediaProvider.notifier)
                          .setMuted(!media.muted),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlayOverlay extends StatelessWidget {
  const _PlayOverlay({required this.visible, required this.onTap});

  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: _fade,
        child: ColoredBox(
          color: colors[NeriToken.scrim].withValues(alpha: _scrimOpacity),
          child: Center(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: sizing.dimen(NeriDimen.avatarSm),
                height: sizing.dimen(NeriDimen.avatarSm),
                decoration: BoxDecoration(
                  color: colors[NeriToken.primary],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Symbols.play_arrow_rounded,
                  fill: 1,
                  size: sizing.dimen(NeriDimen.avatarSm) * 0.6,
                  color: colors[NeriToken.text],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MuteButton extends StatelessWidget {
  const _MuteButton({required this.muted, required this.onTap});

  final bool muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final size = sizing.dimen(NeriDimen.iconMd);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors[NeriToken.scrim],
          shape: BoxShape.circle,
        ),
        child: Icon(
          muted ? Symbols.volume_off_rounded : Symbols.volume_up_rounded,
          fill: 1,
          size: size * 0.6,
          color: colors[NeriToken.text],
        ),
      ),
    );
  }
}
