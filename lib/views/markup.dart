import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/models/user.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/utils/emoji_shortcodes.dart';
import 'package:nerimobile/utils/nevula.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/chat/message/emoji/custom_emoji.dart';
import 'package:nerimobile/views/chat/message/emoji/emoji_size.dart';
import 'package:nerimobile/views/chat/message/emoji/twemoji.dart';

class MarkupRenderContext {
  MarkupRenderContext({
    required this.text,
    required this.channels,
    this.message,
  });

  final String text;
  final Map<String, Channel> channels;
  final Message? message;
  int textCount = 0;
  int emojiCount = 0;

  bool get largeEmoji => emojiCount <= 5 && textCount == 0;

  String slice(Span span) => text.substring(span.start, span.end);

  String countText(String text) {
    if (text.trim().isNotEmpty) textCount += text.length;
    return text;
  }
}

TextSpan transformCustomTextSpan(Entity entity, MarkupRenderContext ctx) {
  final String customType = entity.params["type"] ?? "";
  final String content = ctx.slice(entity.innerSpan);

  // debugPrint('$customType $content');

  switch (customType) {
    case "#":
      final channel = ctx.channels[content];

      if (channel != null && channel.name != null) {
        ctx.countText(content);
        return channelMention(channel);
      }

    case "@":
      final user = ctx.message?.mentions
          .where((u) => u.id == content)
          .firstOrNull;

      if (user != null) {
        ctx.countText(content);
        return userMention(user);
      }

    case "ce":
    case "ace":
    case "wace":
      final kind = CustomEmojiKind.fromType(customType)!;
      final [id, ...rest] = content.split(':');
      ctx.emojiCount++;
      return customEmoji(id, rest.join(':'), kind);
  }
  return TextSpan(text: ctx.countText("[$customType:$content]"));
}

TextSpan customEmoji(String id, String name, CustomEmojiKind kind) {
  return TextSpan(
    children: [
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: CustomEmoji(id: id, name: name, kind: kind),
      ),
    ],
  );
}

TextSpan twemoji(String unicode) {
  return TextSpan(
    children: [
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Twemoji(unicode: unicode),
      ),
    ],
  );
}

TextSpan userMention(User user) {
  return TextSpan(
    children: [
      WidgetSpan(
        child: Container(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(28, 255, 255, 255),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Avatar(size: 16, user: user),
              Text(user.username),
            ],
          ),
        ),
      ),
    ],
  );
}

TextSpan channelMention(Channel channel) {
  return TextSpan(
    children: [
      WidgetSpan(
        child: Container(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(28, 255, 255, 255),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Icon(Symbols.tag_rounded, size: 14),
              Text(channel.name!),
            ],
          ),
        ),
      ),
    ],
  );
}

TextSpan buildTextSpan(Entity entity, MarkupRenderContext ctx) {
  final String content = ctx.slice(entity.innerSpan);

  List<InlineSpan> children() =>
      entity.entities.map((e) => buildTextSpan(e, ctx)).toList();

  switch (entity.type) {
    case "bold":
      return TextSpan(
        children: children(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    case "italic":
      return TextSpan(
        children: children(),
        style: const TextStyle(fontStyle: FontStyle.italic),
      );
    case "underline":
      return TextSpan(
        children: children(),
        style: const TextStyle(decoration: TextDecoration.underline),
      );
    case "strikethrough":
      return TextSpan(
        children: children(),
        style: const TextStyle(decoration: TextDecoration.lineThrough),
      );
    case "spoiler":
      return TextSpan(
        children: children(),
        style: const TextStyle(
          backgroundColor: Colors.black,
          color: Colors.black,
        ),
      );
    case "link":
    case "named_link":
      return TextSpan(
        text: ctx.countText(
          entity.type == "named_link" ? entity.params["name"] : content,
        ),
        style: const TextStyle(color: Colors.blue),
      );
    case "color":
      final colorStr = entity.params["color"] as String;
      Color? color;
      if (colorStr == "reset") {
        color = null;
      } else {
        String hexStr = colorStr.substring(1);
        if (hexStr.length == 3) {
          hexStr = hexStr.split('').map((char) => '$char$char').join();
        }
        color = Color(int.parse('0xFF$hexStr'));
      }
      return TextSpan(
        children: children(),
        style: TextStyle(color: color),
      );
    case "code":
      return TextSpan(
        text: ctx.countText(content),
        style: const TextStyle(
          fontFamily: 'monospace',
          backgroundColor: Colors.grey,
        ),
      );
    case "heading":
      const levelSizes = {1: 34.0, 2: 24.0, 3: 18.0, 4: 14.0, 5: 12.0, 6: 10.0};

      final int level = entity.params["level"] ?? 1;
      double fontSize = levelSizes[level] ?? 14.0;

      return TextSpan(
        children: [
          const WidgetSpan(child: SizedBox(height: 20)),
          TextSpan(
            children: children(),
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
          ),
        ],
      );
    case "custom":
      return transformCustomTextSpan(entity, ctx);
    case "emoji":
      ctx.emojiCount++;
      return twemoji(content);
    case "emoji_name":
      final unicode = emojiShortcodes[content];
      if (unicode == null) {
        return TextSpan(text: ctx.countText(ctx.slice(entity.outerSpan)));
      }
      ctx.emojiCount++;
      return twemoji(unicode);
    case "text":
    default:
      final spans = children();
      return TextSpan(
        text: spans.isEmpty ? ctx.countText(content) : null,
        children: spans,
      );
  }
}

class MarkupView extends ConsumerWidget {
  final String? rawText;
  final Message? message;

  const MarkupView({super.key, this.rawText, this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Entity rootEntity = parseMarkup(rawText ?? '');

    Entity fullEntityTree = addTextSpans(rootEntity);

    final ctx = MarkupRenderContext(
      text: rawText ?? '',
      channels: ref.watch(channelsProvider),
      message: message,
    );
    final span = buildTextSpan(fullEntityTree, ctx);

    return EmojiSizeScope(
      size: ctx.largeEmoji ? largeEmojiSize : emojiSize,
      child: Text.rich(span),
    );
  }
}
