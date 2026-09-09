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
import 'package:nerimobile/utils/format.dart';
import 'package:nerimobile/utils/image.dart';
import 'package:nerimobile/utils/url.dart';
import 'package:nerimobile/views/chat/attachment_expiry.dart';
import 'package:nerimobile/views/chat/audio/audio_player.dart';
import 'package:nerimobile/views/chat/video/video_player.dart';

const _maxWidth = 600.0;
const _maxHeight = 350.0;
const _fallbackRatio = 4 / 3;

class MessageMedia extends StatelessWidget {
  const MessageMedia({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;
    final attachment = message.attachments.firstOrNull;
    final embed = message.embed;

    final media = <Widget>[
      if (attachment != null) _Attachment(attachment: attachment),
      if (attachment == null && embed != null) _EmbedView(embed: embed),
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
  const _Attachment({required this.attachment});

  final Attachment attachment;

  @override
  Widget build(BuildContext context) {
    final path = attachment.path;
    if (path == null) return const SizedBox.shrink();

    if (attachment.isExpired) return _FileCard(attachment: attachment);
    if (attachment.isAudio) return AudioPlayer(attachment: attachment);
    if (attachment.isVideo) return VideoPlayer(attachment: attachment);
    if (!attachment.isImage) return _FileCard(attachment: attachment);

    return _Media(
      url: buildImageUrl(path, animate: true),
      width: attachment.width?.toDouble(),
      height: attachment.height?.toDouble(),
    );
  }
}

class _EmbedView extends StatelessWidget {
  const _EmbedView({required this.embed});

  final Embed embed;

  @override
  Widget build(BuildContext context) {
    final image = embed.imageUrl == null
        ? null
        : _Media(
            url: embed.imageUrl!,
            width: embed.imageWidth?.toDouble(),
            height: embed.imageHeight?.toDouble(),
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
  const _Media({required this.url, this.width, this.height});

  final String url;
  final double? width;
  final double? height;

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

        return ClipRRect(
          borderRadius: sizing.rounded(NeriRadiusRole.image),
          child: Image.network(
            url,
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => const _FileCard(),
          ),
        );
      },
    );
  }
}

class _FileCard extends StatelessWidget {
  const _FileCard({this.attachment});

  final Attachment? attachment;

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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
