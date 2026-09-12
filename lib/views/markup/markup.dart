import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/models/user.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/utils/emoji_shortcodes.dart';
import 'package:nerimobile/utils/nevula.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/chat/message/emoji/custom_emoji.dart';
import 'package:nerimobile/views/chat/message/emoji/emoji_size.dart';
import 'package:nerimobile/views/chat/message/emoji/twemoji.dart';
import 'package:nerimobile/views/markup/spoiler.dart';

class MarkupRenderContext {
  MarkupRenderContext({
    required this.text,
    required this.channels,
    required this.spoilers,
    required this.spoilerBackground,
    required this.spoilerPressedBackground,
    this.message,
  });

  final String text;
  final Map<String, Channel> channels;
  final SpoilerController spoilers;
  final Color spoilerBackground;
  final Color spoilerPressedBackground;
  final Message? message;
  int textCount = 0;
  int emojiCount = 0;
  int spoilerCount = 0;
  int spoilerDepth = 0;
  int? hiddenSpoiler;
  bool spoiledEmoji = false;

  bool get largeEmoji => emojiCount <= 5 && textCount == 0 && !spoiledEmoji;

  bool get hidden => hiddenSpoiler != null;

  Color? hide(Color? color) => hidden ? Colors.transparent : color;

  GestureRecognizer? get spoilerTap =>
      hidden ? spoilers.recognizer(hiddenSpoiler!) : null;
  Color spoilerColor(int index) =>
      spoilers.isPressed(index) ? spoilerPressedBackground : spoilerBackground;

  Widget cover(Widget child) {
    final index = hiddenSpoiler;
    if (index == null) return child;

    return SpoilerCover(
      color: spoilerColor(index),
      onTap: () => spoilers.reveal(index),
      onPressed: (pressed) => spoilers.press(index, pressed),
      child: child,
    );
  }

  String slice(Span span) => text.substring(span.start, span.end);

  String countText(String text) {
    if (text.trim().isNotEmpty) textCount += text.length;
    return text;
  }

  //spoilered emoji stays at text size
  void countEmoji() {
    emojiCount++;
    if (spoilerDepth > 0) spoiledEmoji = true;
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
        return channelMention(channel, ctx);
      }

    case "@":
      final user = ctx.message?.mentions
          .where((u) => u.id == content)
          .firstOrNull;

      if (user != null) {
        ctx.countText(content);
        return userMention(user, ctx);
      }

    case "ce":
    case "ace":
    case "wace":
      final kind = CustomEmojiKind.fromType(customType)!;
      final [id, ...rest] = content.split(':');
      ctx.countEmoji();
      return customEmoji(id, rest.join(':'), kind, ctx);
  }
  return TextSpan(
    text: ctx.countText("[$customType:$content]"),
    recognizer: ctx.spoilerTap,
  );
}

TextSpan customEmoji(
  String id,
  String name,
  CustomEmojiKind kind,
  MarkupRenderContext ctx,
) {
  return TextSpan(
    children: [
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: ctx.cover(CustomEmoji(id: id, name: name, kind: kind)),
      ),
    ],
  );
}

TextSpan twemoji(String unicode, MarkupRenderContext ctx) {
  return TextSpan(
    children: [
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: ctx.cover(Twemoji(unicode: unicode)),
      ),
    ],
  );
}

TextSpan userMention(User user, MarkupRenderContext ctx) {
  return TextSpan(
    children: [
      WidgetSpan(
        child: ctx.cover(
          Container(
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
      ),
    ],
  );
}

TextSpan channelMention(Channel channel, MarkupRenderContext ctx) {
  return TextSpan(
    children: [
      WidgetSpan(
        child: ctx.cover(
          Container(
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
      final index = ctx.spoilerCount++;
      final revealed = ctx.spoilers.isRevealed(index);

      final outer = ctx.hiddenSpoiler;
      if (!revealed) ctx.hiddenSpoiler = index;
      ctx.spoilerDepth++;
      final spoilerSpans = children();
      ctx.spoilerDepth--;
      ctx.hiddenSpoiler = outer;

      if (revealed) return TextSpan(children: spoilerSpans);

      return TextSpan(
        children: spoilerSpans,
        style: TextStyle(
          backgroundColor: ctx.spoilerColor(index),
          color: Colors.transparent,
        ),
      );
    case "link":
    case "named_link":
      return TextSpan(
        text: ctx.countText(
          entity.type == "named_link" ? entity.params["name"] : content,
        ),
        style: TextStyle(color: ctx.hide(Colors.blue)),
        recognizer: ctx.spoilerTap,
      );
    case "color":
      final textBefore = ctx.textCount;
      final spans = children();
      if (ctx.textCount == textBefore) {
        final prefix = ctx.text.substring(
          entity.outerSpan.start,
          entity.innerSpan.start,
        );
        final suffix = ctx.text.substring(
          entity.innerSpan.end,
          entity.outerSpan.end,
        );
        return TextSpan(
          children: [
            TextSpan(text: ctx.countText(prefix), recognizer: ctx.spoilerTap),
            ...spans,
            TextSpan(text: ctx.countText(suffix), recognizer: ctx.spoilerTap),
          ],
        );
      }

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
        children: spans,
        style: TextStyle(color: ctx.hide(color)),
      );
    case "code":
      return TextSpan(
        text: ctx.countText(content),
        style: const TextStyle(
          fontFamily: 'monospace',
          backgroundColor: Colors.grey,
        ),
        recognizer: ctx.spoilerTap,
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
      ctx.countEmoji();
      return twemoji(content, ctx);
    case "emoji_name":
      final unicode = emojiShortcodes[content];
      if (unicode == null) {
        return TextSpan(
          text: ctx.countText(ctx.slice(entity.outerSpan)),
          recognizer: ctx.spoilerTap,
        );
      }
      ctx.countEmoji();
      return twemoji(unicode, ctx);
    case "text":
    default:
      final spans = children();
      return TextSpan(
        text: spans.isEmpty ? ctx.countText(content) : null,
        children: spans,
        recognizer: spans.isEmpty ? ctx.spoilerTap : null,
      );
  }
}

class MarkupView extends ConsumerStatefulWidget {
  final String? rawText;
  final Message? message;

  const MarkupView({super.key, this.rawText, this.message});

  @override
  ConsumerState<MarkupView> createState() => _MarkupViewState();
}

class _MarkupViewState extends ConsumerState<MarkupView> {
  late final _spoilers = SpoilerController(onChanged: () => setState(() {}));

  @override
  void didUpdateWidget(MarkupView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rawText != widget.rawText) _spoilers.reset();
  }

  @override
  void dispose() {
    _spoilers.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Entity rootEntity = parseMarkup(widget.rawText ?? '');

    Entity fullEntityTree = addTextSpans(rootEntity);

    final ctx = MarkupRenderContext(
      text: widget.rawText ?? '',
      channels: ref.watch(channelsProvider),
      spoilers: _spoilers,
      spoilerBackground: context.neri[NeriToken.markupSpoilerBackground],
      spoilerPressedBackground:
          context.neri[NeriToken.markupSpoilerBackgroundHover],
      message: widget.message,
    );
    final span = buildTextSpan(fullEntityTree, ctx);

    return EmojiSizeScope(
      size: ctx.largeEmoji ? largeEmojiSize : emojiSize,
      child: Text.rich(span),
    );
  }
}
