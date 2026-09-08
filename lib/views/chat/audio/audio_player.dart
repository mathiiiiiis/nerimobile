import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/stores/audio/audio_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/format.dart';
import 'package:nerimobile/utils/image.dart';
import 'package:nerimobile/utils/url.dart';
import 'package:nerimobile/views/chat/attachment_expiry.dart';

const _maxWidth = 300.0;
const _trackHeight = 5.0;
const _thumbSize = 8.5;

const _iconSwap = Duration(milliseconds: 150);
const _press = Duration(milliseconds: 100);

class AudioPlayer extends ConsumerWidget {
  const AudioPlayer({super.key, required this.attachment});

  final Attachment attachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = attachment.path;
    if (path == null) return const SizedBox.shrink();

    final colors = context.neri;
    final sizing = context.neriSize;
    final control = sizing.dimen(NeriDimen.avatarSm);

    final url = buildImageUrl(path);
    final audio = ref.watch(audioProvider);
    final current = audio.isCurrent(url);

    final total = current && audio.duration != null
        ? audio.duration!
        : Duration(seconds: attachment.duration ?? 0);
    final elapsed = current ? audio.position : Duration.zero;
    final progress = total > Duration.zero
        ? (elapsed.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Container(
        padding: EdgeInsets.all(sizing.space(NeriSpacingRole.lg)),
        decoration: BoxDecoration(
          color: colors[NeriToken.background],
          borderRadius: sizing.rounded(NeriRadiusRole.xl),
          border: Border.all(
            color: colors[NeriToken.border],
            width: sizing.border(NeriBorderRole.hairline),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: sizing.space(NeriSpacingRole.lg),
          children: [
            Row(
              spacing: sizing.space(NeriSpacingRole.lg),
              children: [
                _PlayButton(
                  size: control,
                  playing: current && audio.playing,
                  onTap: () => ref.read(audioProvider.notifier).toggle(url),
                ),
                Expanded(
                  child: _Details(attachment: attachment, path: path),
                ),
              ],
            ),
            _Progress(
              progress: progress,
              elapsed: elapsed,
              total: total,
              onSeek: (value) =>
                  ref.read(audioProvider.notifier).seek(url, total * value),
            ),
          ],
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.attachment, required this.path});

  final Attachment attachment;
  final String path;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final size = attachment.filesize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          filenameFromPath(path),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.neriText[NeriTextRole.bodyMedium].copyWith(
            color: colors[NeriToken.text],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(
              size == null ? (attachment.mime ?? '') : formatFileSize(size),
              style: context.neriText[NeriTextRole.labelSmall].copyWith(
                color: colors[NeriToken.textPlaceholder],
              ),
            ),
            if (attachment.expireAt != null)
              AttachmentExpiry(expireAt: attachment.expireAt!),
          ],
        ),
      ],
    );
  }
}

class _PlayButton extends StatefulWidget {
  const _PlayButton({
    required this.size,
    required this.playing,
    required this.onTap,
  });

  final double size;
  final bool playing;
  final VoidCallback onTap;

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.88 : 1,
        duration: _press,
        curve: Curves.easeOut,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: colors[NeriToken.primary],
            shape: BoxShape.circle,
          ),
          child: AnimatedSwitcher(
            duration: _iconSwap,
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              widget.playing
                  ? Symbols.pause_rounded
                  : Symbols.play_arrow_rounded,
              key: ValueKey(widget.playing),
              fill: 1,
              size: widget.size * 0.6,
              color: colors[NeriToken.text],
            ),
          ),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({
    required this.progress,
    required this.elapsed,
    required this.total,
    required this.onSeek,
  });

  final double progress;
  final Duration elapsed;
  final Duration total;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final label = context.neriText[NeriTextRole.labelSmall].copyWith(
      color: colors[NeriToken.textPlaceholder],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: sizing.space(NeriSpacingRole.xs),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatDuration(elapsed), style: label),
            Text(formatDuration(total), style: label),
          ],
        ),
        LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) =>
                onSeek(details.localPosition.dx / constraints.maxWidth),
            onHorizontalDragUpdate: (details) => onSeek(
              (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0),
            ),
            child: SizedBox(
              height: _thumbSize * 2,
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
                        color: colors[NeriToken.text],
                        borderRadius: BorderRadius.circular(_trackHeight / 2),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(progress * 2 - 1, 0),
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: BoxDecoration(
                        color: colors[NeriToken.text],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
