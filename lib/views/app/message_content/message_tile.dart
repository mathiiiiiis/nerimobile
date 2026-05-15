import 'package:flutter/material.dart';
import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/stores/pane_size_store.dart';
import 'package:nerimobile/stores/server_store.dart';
import 'package:nerimobile/stores/window_focus_store.dart';
import 'package:nerimobile/utils/colors.dart';
import 'package:nerimobile/utils/date.dart';
import 'package:nerimobile/utils/image.dart';
import 'package:nerimobile/utils/url.dart';
import 'package:nerimobile/views/app/server_clan_tag.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/cdn_icon.dart';
import 'package:nerimobile/views/markup.dart';
import 'package:signals/signals_flutter.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final Message? prevMessage;
  const MessageTile({super.key, required this.message, this.prevMessage});

  @override
  Widget build(BuildContext context) {
    final prevSameCreator =
        prevMessage != null &&
        prevMessage!.createdBy.id == message.createdBy.id;

    final isUnderFiveMinutes = prevMessage == null
        ? true
        : message.createdAt - prevMessage!.createdAt < 5 * 60 * 1000;

    final hasMessageReplies = message.replyMessages.isNotEmpty;

    final hideExtraDetails =
        prevSameCreator && isUnderFiveMinutes && !hasMessageReplies;

    final clan = message.createdBy.profile?.clan;

    final isImageEmbedOnly =
        message.embed?.type == EmbedType.image.name &&
        !message.content.contains(" ") &&
        isValidUrl(message.content);

    return Container(
      margin: !hideExtraDetails
          ? const EdgeInsets.only(top: 12.0)
          : const EdgeInsets.only(top: 0),
      child: InkWell(
        onTap: () {},
        hoverColor: const Color.fromARGB(19, 255, 255, 255),
        child: Container(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              if (hasMessageReplies) MessageReplies(message: message),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  hideExtraDetails
                      ? SizedBox(width: AvatarSize.lg.value, height: 1)
                      : Avatar(user: message.createdBy, size: AvatarSize.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        if (!hideExtraDetails)
                          Watch((context) {
                            final member = serverStore
                                .currentServerMembers
                                .value?[message.createdBy.id];
                            final topcolorAndIcon = serverStore
                                .memberTopColorAndIcon(member);
                            return Row(
                              spacing: 4,
                              children: [
                                buildColoredName(
                                  hexColor: topcolorAndIcon?.hexColor,
                                  member?.nickname ??
                                      message.createdBy.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (clan != null) ServerClanTag(clan: clan),
                                if (topcolorAndIcon?.icon != null)
                                  CdnIcon(
                                    path: topcolorAndIcon!.icon,
                                    size: 12,
                                  ),
                                Text(
                                  formatTimestamp(message.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            );
                          }),
                        if (!isImageEmbedOnly && message.content.isNotEmpty)
                          MarkupView(
                            rawText: message.content,
                            message: message,
                          ),
                        MessageEmbeds(message: message),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageEmbeds extends StatelessWidget {
  final Message message;
  const MessageEmbeds({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final attachment = message.attachments.firstOrNull;

    final imageAttachment =
        attachment?.width != null &&
        attachment?.mime?.startsWith("image/") == true;

    final imageEmbed =
        message.embed?.type == EmbedType.image.name &&
        message.embed?.imageHeight != null;

    return (imageAttachment || imageEmbed)
        ? MessageImageEmbed(
            attachment: attachment,
            embed: message.embed,
            message: message,
          )
        : const SizedBox.shrink();
  }
}

class MessageImageEmbed extends StatelessWidget {
  final Message message;
  final Attachment? attachment;
  final Embed? embed;
  const MessageImageEmbed({
    super.key,
    required this.message,
    this.attachment,
    this.embed,
  });

  @override
  Widget build(BuildContext context) {
    var path = "";

    if (attachment?.path != null) {
      path = attachment!.path!;
    } else {
      final unsafeUrl = embed?.imageUrl as String;
      if (unsafeUrl.startsWith("https://") || unsafeUrl.startsWith("http://")) {
        path = unsafeUrl;
      } else {
        path = "https://$unsafeUrl";
      }
      path = "proxy/${Uri.encodeComponent(path)}/embed.webp";
    }

    final width = attachment?.width ?? embed?.imageWidth ?? 0;
    final height = attachment?.height ?? embed?.imageHeight ?? 0;

    return Watch((context) {
      final avatarOffset =
          AvatarSize.lg.value +
          8 +
          8 +
          8; // avatar + spacing + left/right padding
      final maxWidth = (paneWidth.value - avatarOffset).clamp(0, 1920);
      final maxHeight = (paneHeight.value / 2).clamp(0, 600);

      final size = constrainDimensions(
        width: width.toDouble(),
        height: height.toDouble(),
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
      );

      final url = buildImageUrl(
        path,
        forceIsAnimated: embed?.animated,
        animate: isWindowFocused.value,
      );

      return UnconstrainedBox(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              width: size.width,
              height: size.height,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                  child: child,
                );
              },
            ),
          ),
        ),
      );
    });
  }
}

class MessageReplies extends StatelessWidget {
  final Message message;
  const MessageReplies({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final replies = message.replyMessages;
    return Opacity(
      opacity: 0.8,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        child: Stack(
          children: [
            Positioned(
              left: 18,
              top: 10,
              bottom: 0,
              child: SizedBox(
                width: AvatarSize.lg.value - 18,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white30, width: 2),
                      left: BorderSide(color: Colors.white30, width: 2),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: AvatarSize.lg.value + 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: replies
                    .map(
                      (reply) =>
                          MessageReplyTile(message: reply.replyToMessage),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageReplyTile extends StatelessWidget {
  final PartialMessage? message;
  const MessageReplyTile({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    var content = message?.content ?? "";
    if (message == null) content = "Deleted Message";
    if ((message?.attachments.isNotEmpty ?? false) && content.isEmpty) {
      content = "Attachment Message";
    }

    return Watch((context) {
      final member =
          serverStore.currentServerMembers.value?[message?.createdBy.id];
      final topColor = serverStore.memberTopColor(member);
      return Row(
        spacing: 6,
        children: [
          if (message?.createdBy != null)
            buildColoredName(
              hexColor: topColor,
              member?.nickname ?? message!.createdBy.username,
              style: const TextStyle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Flexible(
            child: Text(content, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    });
  }
}
