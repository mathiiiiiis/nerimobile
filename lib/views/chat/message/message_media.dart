import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/stores/message/upload_progress_store.dart';
import 'package:nerimobile/stores/window/window_focus_store.dart';
import 'package:nerimobile/theme/sizing/border.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/caches.dart';
import 'package:nerimobile/utils/format.dart';
import 'package:nerimobile/utils/image.dart';
import 'package:nerimobile/utils/url.dart';
import 'package:nerimobile/views/chat/attachment_expiry.dart';
import 'package:nerimobile/views/chat/audio/audio_player.dart';
import 'package:nerimobile/views/chat/fullscreen/fullscreen_shell.dart';
import 'package:nerimobile/views/chat/fullscreen/image_fullscreen.dart';
import 'package:nerimobile/views/chat/video/video_player.dart';
import 'package:nerimobile/views/skeleton/skeleton.dart';

const _maxWidth = 600.0;
const _maxHeight = 350.0;
const _fallbackRatio = 4 / 3;
const _scrimOpacity = 0.45;
const _trackOpacity = 0.3;
const _progressEase = Duration(milliseconds: 200);
const _overlayFade = Duration(milliseconds: 200);

class MediaPreview extends StatelessWidget {
  const MediaPreview({
    super.key,
    required this.attachments,
    this.embed,
    this.onOptions,
  });

  final List<Attachment> attachments;
  final Embed? embed;
  final OptionsCallback? onOptions;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final attachment = attachments.firstOrNull;
    final embed = this.embed;

    final media = <Widget>[
      if (attachment != null)
        _Attachment(attachment: attachment, onOptions: onOptions),
      if (attachment == null && embed != null)
        _EmbedView(embed: embed, onOptions: onOptions),
    ];
    if (media.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: sizing.space(NeriSpacingRole.sm)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: sizing.space(NeriSpacingRole.sm),
        children: media,
      ),
    );
  }
}

class _Attachment extends StatelessWidget {
  const _Attachment({required this.attachment, this.onOptions});

  final Attachment attachment;
  final OptionsCallback? onOptions;

  @override
  Widget build(BuildContext context) {
    final path = attachment.path;
    if (path == null) return const SizedBox.shrink();

    if (attachment.onDevice) {
      return attachment.isImage
          ? _Media.file(File(path), uploadId: attachment.id)
          : _FileCard(attachment: attachment, uploadId: attachment.id);
    }
    if (attachment.isExpired) return _FileCard(attachment: attachment);
    if (attachment.isAudio) return AudioPlayer(attachment: attachment);
    if (attachment.isVideo) {
      return VideoPlayer(attachment: attachment, onOptions: onOptions);
    }
    if (!attachment.isImage) return _FileCard(attachment: attachment);

    return _Media(
      url: (_) => buildImageUrl(path, animate: true),
      width: attachment.width?.toDouble(),
      height: attachment.height?.toDouble(),
      onOptions: onOptions,
    );
  }
}

class _EmbedView extends ConsumerWidget {
  const _EmbedView({required this.embed, this.onOptions});

  final Embed embed;
  final OptionsCallback? onOptions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animate = ref.watch(windowFocusProvider);
    final source = embed.imageSource;
    final image = source == null
        ? null
        : _Media(
            url: (pixels) => buildImageUrl(
              proxiedEmbedPath(source, mime: embed.imageMime),
              size: pixels,
              animate: animate,
              forceIsAnimated: embed.animated,
            ),
            link: source,
            width: embed.imageWidth?.toDouble(),
            height: embed.imageHeight?.toDouble(),
            onOptions: onOptions,
          );
    if (!embed.hasDetails) return image ?? const SizedBox.shrink();
    return _LinkCard(embed: embed, image: image);
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({required this.embed, this.image});

  final Embed embed;
  final Widget? image;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;
    final text = context.neriText;

    return Container(
      padding: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
      decoration: BoxDecoration(
        color: colors[NeriToken.card],
        borderRadius: sizing.rounded(NeriRadiusRole.image),
        border: Border.all(
          color: colors[NeriToken.border],
          width: sizing.border(NeriBorderRole.hairline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: sizing.space(NeriSpacingRole.xs),
        children: [
          if (embed.siteName != null || embed.domain != null)
            Text(
              embed.siteName ?? embed.domain!,
              style: text[NeriTextRole.labelSmall].copyWith(
                color: colors[NeriToken.textPlaceholder],
              ),
            ),
          if (embed.title != null)
            Text(
              embed.title!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text[NeriTextRole.labelLarge].copyWith(
                color: colors[NeriToken.text],
              ),
            ),
          if (embed.description != null)
            Text(
              embed.description!,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: text[NeriTextRole.bodySmall].copyWith(
                color: colors[NeriToken.textSecondary],
              ),
            ),
          if (embed.channelName != null)
            Text(
              embed.channelName!,
              style: text[NeriTextRole.labelSmall].copyWith(
                color: colors[NeriToken.textPlaceholder],
              ),
            ),
          ?image,
        ],
      ),
    );
  }
}

class _Media extends StatelessWidget {
  const _Media({
    required String Function(int pixels) this.url,
    this.link,
    this.width,
    this.height,
    this.onOptions,
  }) : file = null,
       uploadId = null;

  const _Media.file(File this.file, {this.uploadId})
    : url = null,
      link = null,
      width = null,
      height = null,
      onOptions = null;

  final String? Function(int pixels)? url;
  final String? link;
  final File? file;
  final String? uploadId;
  final double? width;
  final double? height;
  final OptionsCallback? onOptions;

  ImageProvider _image(String? url) => switch (file) {
    final file? => FileImage(file),
    null => CachedNetworkImageProvider(url!, cacheManager: mediaCache),
  };

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.clamp(0.0, _maxWidth);
        final size = constrainDimensions(
          width: width ?? available,
          height: height ?? available / _fallbackRatio,
          maxWidth: available,
          maxHeight: _maxHeight,
        );
        final pixels =
            max(size.width, size.height) *
            MediaQuery.devicePixelRatioOf(context);
        final url = this.url?.call(pixels.round());

        return GestureDetector(
          onTap: () {
            final box = context.findRenderObject()! as RenderBox;
            openImageFullscreen(
              context,
              _image(url),
              from: box.localToGlobal(Offset.zero) & box.size,
              url: link ?? url,
              onOptions: onOptions,
            );
          },
          child: ClipRRect(
            borderRadius: sizing.rounded(NeriRadiusRole.image),
            child: switch (file) {
              final file? => Stack(
                children: [
                  TickerMode(
                    enabled: false,
                    child: Image.file(
                      file,
                      width: size.width,
                      height: size.height,
                      fit: BoxFit.cover,
                      cacheWidth:
                          (size.width * MediaQuery.devicePixelRatioOf(context))
                              .round(),
                      errorBuilder: (_, _, _) => _FileCard(),
                    ),
                  ),
                  if (uploadId case final uploadId?)
                    Positioned.fill(child: _UploadOverlay(uploadId: uploadId)),
                ],
              ),
              null => CachedNetworkImage(
                imageUrl: url!,
                cacheManager: mediaCache,
                width: size.width,
                height: size.height,
                fit: BoxFit.cover,
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                useOldImageOnUrlChange: true,
                placeholder: (_, _) => SkeletonScope(
                  child: SkeletonBlock(
                    width: size.width,
                    height: size.height,
                    shape: NeriRadiusRole.image,
                  ),
                ),
                errorWidget: (_, _, _) => const _FileCard(),
              ),
            },
          ),
        );
      },
    );
  }
}

class _UploadOverlay extends ConsumerWidget {
  const _UploadOverlay({required this.uploadId});

  final String uploadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(uploadProgressProvider(uploadId));
    final sizing = context.neriSize;
    final ring = sizing.dimen(NeriDimen.uploadRing);
    final stroke = sizing.border(NeriBorderRole.thick);

    return AnimatedSwitcher(
      duration: _overlayFade,
      child: progress == null
          ? const SizedBox.expand()
          : ColoredBox(
              color: Colors.black.withValues(alpha: _scrimOpacity),
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: progress),
                  duration: _progressEase,
                  builder: (context, value, _) => value >= 1
                      //all bytes out, cdn is still processing
                      ? Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            SizedBox.square(
                              dimension: ring,
                              child: CircularProgressIndicator(
                                strokeWidth: stroke,
                                strokeCap: StrokeCap.round,
                                color: Colors.white,
                                backgroundColor: Colors.white.withValues(
                                  alpha: _trackOpacity,
                                ),
                              ),
                            ),
                            Positioned(
                              top: ring + sizing.space(NeriSpacingRole.sm),
                              child: Text(
                                'Still processing...', //TODO: add l10n
                                style: context.neriText[NeriTextRole.labelSmall]
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        )
                      : CustomPaint(
                          painter: _RingPainter(
                            progress: value,
                            stroke: stroke,
                          ),
                          child: SizedBox.square(
                            dimension: ring,
                            child: Center(
                              child: Text(
                                '${(value * 100).round()}%',
                                style: context.neriText[NeriTextRole.labelSmall]
                                    .copyWith(
                                      color: Colors.white,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.stroke});

  final double progress;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    paint.color = Colors.white.withValues(alpha: _trackOpacity);
    canvas.drawArc(rect, 0, 2 * pi, false, paint);

    if (progress <= 0) return;
    paint.color = Colors.white;
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.stroke != stroke;
}

class _FileCard extends StatelessWidget {
  const _FileCard({this.attachment, this.uploadId});

  final Attachment? attachment;
  final String? uploadId;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return Container(
      padding: EdgeInsets.all(sizing.space(NeriSpacingRole.md)),
      decoration: BoxDecoration(
        color: colors[NeriToken.card],
        borderRadius: sizing.rounded(NeriRadiusRole.image),
        border: Border.all(
          color: colors[NeriToken.border],
          width: sizing.border(NeriBorderRole.hairline),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: sizing.space(NeriSpacingRole.sm),
        children: [
          Icon(
            Symbols.attach_file_rounded,
            size: sizing.dimen(NeriDimen.iconSm),
            color: colors[NeriToken.textSecondary],
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attachment?.path == null
                      ? 'Attachment' //TODO: add l10n
                      : filenameFromPath(attachment!.path!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.neriText[NeriTextRole.bodySmall].copyWith(
                    color: colors[NeriToken.textSecondary],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: sizing.space(NeriSpacingRole.sm),
                  children: [
                    if (attachment?.filesize != null)
                      Text(
                        formatFileSize(attachment!.filesize!),
                        style: context.neriText[NeriTextRole.labelSmall]
                            .copyWith(color: colors[NeriToken.textPlaceholder]),
                      ),
                    if (attachment?.expireAt != null)
                      AttachmentExpiry(expireAt: attachment!.expireAt!),
                  ],
                ),
                if (uploadId case final uploadId?)
                  _UploadBar(uploadId: uploadId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadBar extends ConsumerWidget {
  const _UploadBar({required this.uploadId});

  final String uploadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(uploadProgressProvider(uploadId));
    if (progress == null) return const SizedBox.shrink();

    final colors = context.neri;
    final sizing = context.neriSize;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: progress),
      duration: _progressEase,
      builder: (context, value, _) {
        final processing = value >= 1;

        return Row(
          spacing: sizing.space(NeriSpacingRole.sm),
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: processing ? null : value,
                minHeight: sizing.border(NeriBorderRole.thick),
                borderRadius: sizing.rounded(NeriRadiusRole.full),
                color: colors[NeriToken.primary],
                backgroundColor: colors[NeriToken.border],
              ),
            ),
            Text(
              processing
                  ? 'Still processing...' //TODO: add l10n
                  : '${(value * 100).round()}%',
              style: context.neriText[NeriTextRole.labelSmall].copyWith(
                color: colors[NeriToken.textPlaceholder],
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );
      },
    );
  }
}
