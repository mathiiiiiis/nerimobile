import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:nerimobile/models/channel.dart';
import 'package:nerimobile/models/message.dart';
import 'package:nerimobile/models/server_role.dart';
import 'package:nerimobile/models/user.dart';
import 'package:nerimobile/stores/channel/channel_store.dart';
import 'package:nerimobile/stores/server/server_roles_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/sizing.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/utils/colors.dart';
import 'package:nerimobile/utils/date.dart';
import 'package:nerimobile/utils/emoji_shortcodes.dart';
import 'package:nerimobile/utils/nevula.dart';
import 'package:nerimobile/utils/url.dart';
import 'package:nerimobile/views/avatar.dart';
import 'package:nerimobile/views/chat/message/emoji/custom_emoji.dart';
import 'package:nerimobile/views/chat/message/emoji/emoji_size.dart';
import 'package:nerimobile/views/chat/message/emoji/twemoji.dart';
import 'package:nerimobile/views/markup/blockquote.dart';
import 'package:nerimobile/views/markup/checkbox.dart';
import 'package:nerimobile/views/markup/code_block.dart';
import 'package:nerimobile/views/markup/gradient.dart';
import 'package:nerimobile/views/markup/link_taps.dart';
import 'package:nerimobile/views/markup/mention_chip.dart';
import 'package:nerimobile/views/markup/quote_message.dart';
import 'package:nerimobile/views/markup/spoiler.dart';
import 'package:nerimobile/views/modal/confirm_dialog.dart';

const _checkboxScale = 1.1;
const _maxQuotes = 10;
const _relativeTick = Duration(seconds: 30);
const _countdownTick = Duration(seconds: 1);
const _countdownRange = Duration(minutes: 1);
const _headingRoles = {
  1: NeriTextRole.headlineLarge,
  2: NeriTextRole.headlineMedium,
  3: NeriTextRole.titleLarge,
  4: NeriTextRole.headlineSmall,
  5: NeriTextRole.titleMedium,
  6: NeriTextRole.titleSmall,
};

class PlaceholderSlot {
  const PlaceholderSlot({this.size, required this.alignment});

  final Size? size;
  final PlaceholderAlignment alignment;
}

class MarkupRenderContext {
  MarkupRenderContext({
    required this.neri,
    required this.sizing,
    required this.textStyles,
    required this.text,
    required this.channels,
    required this.serverRoles,
    required this.spoilers,
    required this.links,
    required this.spoilerBackground,
    required this.spoilerPressedBackground,
    required this.baseStyle,
    required this.textScaler,
    required this.textDirection,
    this.message,
    this.mentions = const [],
    this.inline = false,
    this.isQuote = false,
    this.shaders,
  });

  final NeriColors neri;
  final NeriSizing sizing;
  final NeriTypography textStyles;
  final String text;
  final Map<String, Channel> channels;
  final Map<String, Map<String, ServerRole>> serverRoles;
  final SpoilerController spoilers;
  final LinkTapController links;
  final Color spoilerBackground;
  final Color spoilerPressedBackground;
  final TextStyle baseStyle;
  final TextScaler textScaler;
  final TextDirection textDirection;
  final Message? message;
  final List<User> mentions;
  final bool inline;
  final bool isQuote;
  final List<ui.Shader>? shaders;
  final placeholders = <PlaceholderSlot>[];
  int gradientCount = 0;
  int textCount = 0;
  int emojiCount = 0;
  int spoilerCount = 0;
  int spoilerDepth = 0;
  int relativeCount = 0;
  int quoteCount = 0;
  bool countingSeconds = false;
  int? hiddenSpoiler;
  bool spoiledEmoji = false;
  bool styledEmoji = false;
  double? emojiSizeOverride;

  bool get largeEmoji =>
      !inline &&
      emojiCount <= 5 &&
      textCount == 0 &&
      !spoiledEmoji &&
      !styledEmoji;

  bool get hidden => hiddenSpoiler != null;

  ServerRole? role(String roleId) {
    final serverId = channels[message?.channelId]?.serverId;
    return serverId == null ? null : serverRoles[serverId]?[roleId];
  }

  TextStyle get codeStyle => textStyles.mono.copyWith(
    backgroundColor: neri[NeriToken.markupCodeBackground],
  );

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
    if (emojiSizeOverride != null) styledEmoji = true;
  }

  //emoji size settles after spans are built
  InlineSpan emojiSpan(Widget child) => widgetSpan(
    cover(child),
    size: emojiSizeOverride == null ? null : Size.square(emojiSizeOverride!),
    alignment: PlaceholderAlignment.middle,
  );

  //tracks dimens for measurement pass
  InlineSpan widgetSpan(
    Widget child, {
    Size? size,
    PlaceholderAlignment alignment = PlaceholderAlignment.bottom,
  }) {
    placeholders.add(PlaceholderSlot(size: size, alignment: alignment));
    return WidgetSpan(alignment: alignment, child: child);
  }

  List<PlaceholderDimensions> placeholderDimensions(double emojiSize) => [
    for (final slot in placeholders)
      PlaceholderDimensions(
        size: slot.size ?? Size.square(emojiSize),
        alignment: slot.alignment,
      ),
  ];

  Size chipSize(String label, double leadingSize) => mentionChipSize(
    label: label,
    leadingSize: leadingSize,
    spacing: sizing.space(NeriSpacingRole.xs),
    style: baseStyle,
    textScaler: textScaler,
    textDirection: textDirection,
  );

  //keeps emoji size in sync with resized text
  Widget scaleEmoji(Widget child) {
    final size = emojiSizeOverride;
    if (size == null) return child;

    return EmojiSizeScope(size: size, child: child);
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

    case "link":
      final parts = content.split('->');
      if (parts.length < 2) break;

      final target = withScheme(parts[0].trim());
      final label = parts[1].trim();
      if (target.isEmpty || label.isEmpty) break;

      return linkSpan(target, label, ctx);

    //TODO: add l10n
    case "q":
      if (ctx.isQuote || ctx.inline) return quoteChip('Quote', ctx);

      final quote = ctx.message?.quotedMessages
          .where((m) => m.id == content)
          .firstOrNull;
      if (quote == null) return quoteChip('Unknown message', ctx);
      if (ctx.quoteCount >= _maxQuotes) break;

      ctx.quoteCount++;
      ctx.countText(content);
      return TextSpan(
        children: [ctx.widgetSpan(ctx.cover(QuoteMessageView(quote: quote)))],
      );

    case "to":
      final clock = formatZoneTime(content.trim());
      if (clock == null) break;

      ctx.countText(content);
      ctx.relativeCount++;
      ctx.countingSeconds = true;
      return timestampChip(clock, ctx);

    case "tr":
      final seconds = double.tryParse(content.trim());
      if (seconds == null) break;

      ctx.countText(content);
      ctx.relativeCount++;
      return timestampMention((seconds * 1000).round(), ctx);

    case "r":
      final role = ctx.role(content);

      if (role != null) {
        ctx.countText(content);
        return roleMention(role, ctx);
      }

    case "@":
      final user = [
        ...?ctx.message?.mentions,
        ...ctx.mentions,
      ].where((u) => u.id == content).firstOrNull;

      if (user != null) {
        ctx.countText(content);
        return userMention(user, ctx);
      }

    case "gradient":
      final expr = parseColorExpr(content);
      if (expr == null) break;

      final index = ctx.gradientCount++;
      final shader = ctx.shaders?.elementAtOrNull(index);

      return GradientSpan(
        colors: expr.colors,
        text: ctx.countText(expr.text),
        style: ctx.hidden
            ? const TextStyle(color: Colors.transparent)
            : shader == null
            ? null
            : TextStyle(foreground: Paint()..shader = shader),
        recognizer: ctx.spoilerTap,
      );

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
      ctx.emojiSpan(
        ctx.scaleEmoji(CustomEmoji(id: id, name: name, kind: kind)),
      ),
    ],
  );
}

TextSpan twemoji(String unicode, MarkupRenderContext ctx) {
  return TextSpan(
    children: [ctx.emojiSpan(ctx.scaleEmoji(Twemoji(unicode: unicode)))],
  );
}

TextSpan userMention(User user, MarkupRenderContext ctx) {
  return TextSpan(
    children: [
      ctx.widgetSpan(
        ctx.cover(
          MentionChip(
            leading: Avatar(
              size: ctx.sizing.dimen(NeriDimen.mentionAvatar),
              user: user,
            ),
            label: user.username,
          ),
        ),
        size: ctx.chipSize(
          user.username,
          ctx.sizing.dimen(NeriDimen.mentionAvatar),
        ),
      ),
    ],
  );
}

TextSpan linkSpan(String url, String label, MarkupRenderContext ctx) {
  return TextSpan(
    text: ctx.countText(label),
    style: TextStyle(color: ctx.hide(ctx.neri[NeriToken.primary])),
    recognizer:
        ctx.spoilerTap ?? ctx.links.recognizer(url, masked: label != url),
  );
}

//TODO: tapping a future timestamp should offer a reminder (nerimity web behaviour)
TextSpan timestampMention(int milliseconds, MarkupRenderContext ctx) {
  final target = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  if (target.difference(DateTime.now()).abs() < _countdownRange) {
    ctx.countingSeconds = true;
  }

  return timestampChip(formatRelative(milliseconds), ctx);
}

TextSpan quoteChip(String label, MarkupRenderContext ctx) {
  return TextSpan(
    children: [
      ctx.widgetSpan(
        ctx.cover(
          MentionChip(
            leading: Icon(
              Symbols.format_quote_rounded,
              size: ctx.sizing.dimen(NeriDimen.mentionIcon),
            ),
            label: label,
          ),
        ),
        size: ctx.chipSize(label, ctx.sizing.dimen(NeriDimen.mentionIcon)),
      ),
    ],
  );
}

TextSpan timestampChip(String label, MarkupRenderContext ctx) {
  return TextSpan(
    children: [
      ctx.widgetSpan(
        ctx.cover(
          MentionChip(
            leading: Icon(
              Symbols.schedule_rounded,
              size: ctx.sizing.dimen(NeriDimen.mentionIcon),
            ),
            label: label,
          ),
        ),
        size: ctx.chipSize(label, ctx.sizing.dimen(NeriDimen.mentionIcon)),
      ),
    ],
  );
}

TextSpan roleMention(ServerRole role, MarkupRenderContext ctx) {
  final label = '@${role.name}';
  final color = role.hexColor;

  return TextSpan(
    children: [
      ctx.widgetSpan(
        ctx.cover(
          MentionChip(
            label: label,
            color: color == null ? null : ctx.hide(hexToColor(color)),
          ),
        ),
        size: ctx.chipSize(label, 0),
      ),
    ],
  );
}

TextSpan channelMention(Channel channel, MarkupRenderContext ctx) {
  return TextSpan(
    children: [
      ctx.widgetSpan(
        ctx.cover(
          MentionChip(
            leading: Icon(
              Symbols.tag_rounded,
              size: ctx.sizing.dimen(NeriDimen.mentionIcon),
            ),
            label: channel.name!,
          ),
        ),
        size: ctx.chipSize(
          channel.name!,
          ctx.sizing.dimen(NeriDimen.mentionIcon),
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
      final named = entity.type == "named_link";
      final url = withScheme(named ? entity.params["url"] : content);

      return linkSpan(url, named ? entity.params["name"] : content, ctx);
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
      final spans = children();
      return TextSpan(
        text: spans.isEmpty ? ctx.countText(content) : null,
        children: spans.isEmpty ? null : spans,
        style: ctx.codeStyle,
        recognizer: ctx.spoilerTap,
      );
    case "codeblock":
      final spans = children();
      final code = TextSpan(
        text: spans.isEmpty ? ctx.countText(content) : null,
        children: spans.isEmpty ? null : spans,
      );
      if (ctx.inline) {
        return TextSpan(
          children: [code],
          style: ctx.codeStyle,
          recognizer: ctx.spoilerTap,
        );
      }

      return TextSpan(
        children: [
          ctx.widgetSpan(
            ctx.cover(CodeBlockView(code: code, lang: entity.params["lang"])),
          ),
        ],
      );
    case "blockquote":
      final quoted = TextSpan(children: children());
      if (ctx.inline) return quoted;

      return TextSpan(
        children: [ctx.widgetSpan(ctx.cover(BlockquoteView(content: quoted)))],
      );
    case "checkbox":
      ctx.countText(content);
      final boxSize = (ctx.baseStyle.fontSize ?? 14) * _checkboxScale;

      return TextSpan(
        children: [
          ctx.widgetSpan(
            ctx.cover(
              MarkupCheckbox(
                checked: entity.params["checked"] == true,
                size: boxSize,
              ),
            ),
            size: Size.square(boxSize),
            alignment: PlaceholderAlignment.middle,
          ),
        ],
      );
    case "heading":
      final int level = entity.params["level"] ?? 1;
      final role = _headingRoles[level] ?? NeriTextRole.titleSmall;
      final headingStyle = ctx.textStyles[role];
      final fontSize = headingStyle.fontSize ?? ctx.baseStyle.fontSize;

      if (ctx.inline) return TextSpan(children: children());

      final spacer = ctx.sizing.space(NeriSpacingRole.lg);

      final outerSize = ctx.emojiSizeOverride;
      ctx.emojiSizeOverride = fontSize;
      final headingSpans = children();
      ctx.emojiSizeOverride = outerSize;

      return TextSpan(
        children: [
          ctx.widgetSpan(SizedBox(height: spacer), size: Size(0, spacer)),
          TextSpan(children: headingSpans, style: headingStyle),
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
  final List<User> mentions;

  //keeps custom status markup on one text run
  final bool inline;
  final bool isQuote;
  final int? maxLines;
  final TextOverflow? overflow;

  const MarkupView({
    super.key,
    this.rawText,
    this.message,
    this.mentions = const [],
    this.inline = false,
    this.isQuote = false,
    this.maxLines,
    this.overflow,
  });

  @override
  ConsumerState<MarkupView> createState() => _MarkupViewState();
}

class _MarkupViewState extends ConsumerState<MarkupView> {
  late final _spoilers = SpoilerController(onChanged: () => setState(() {}));
  late final _links = LinkTapController(_openLink);
  Timer? _relativeTicker;
  Duration? _relativeInterval;

  //relative timestamps need periodic redraws
  void _syncRelativeTicker(Duration? interval) {
    if (interval == _relativeInterval) return;

    _relativeTicker?.cancel();
    _relativeInterval = interval;
    _relativeTicker = interval == null
        ? null
        : Timer.periodic(interval, (_) => setState(() {}));
  }

  //masked links require confirmation
  Future<void> _openLink(String url, {required bool masked}) async {
    if (masked) {
      final confirmed = await showConfirmDialog(
        context,
        title: 'Open link?', //TODO: add l10n
        message: url,
        confirmLabel: 'Open', //TODO: add l10n
      );
      if (!confirmed) return;
    }

    openExternal(url);
  }

  @override
  void didUpdateWidget(MarkupView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rawText == widget.rawText) return;

    _spoilers.reset();
    _links.reset();
  }

  @override
  void dispose() {
    _spoilers.reset();
    _links.reset();
    _relativeTicker?.cancel();
    super.dispose();
  }

  MarkupRenderContext _context(
    BuildContext context, {
    List<ui.Shader>? shaders,
  }) {
    return MarkupRenderContext(
      neri: context.neri,
      sizing: context.neriSize,
      textStyles: context.neriText,
      text: widget.rawText ?? '',
      channels: ref.read(channelsProvider),
      serverRoles: ref.read(serverRolesProvider),
      spoilers: _spoilers,
      links: _links,
      spoilerBackground: context.neri[NeriToken.markupSpoilerBackground],
      spoilerPressedBackground:
          context.neri[NeriToken.markupSpoilerBackgroundHover],
      baseStyle: DefaultTextStyle.of(context).style,
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: Directionality.of(context),
      message: widget.message,
      mentions: widget.mentions,
      inline: widget.inline,
      isQuote: widget.isQuote,
      shaders: shaders,
    );
  }

  Widget _text(InlineSpan span, double emojiSize) => EmojiSizeScope(
    size: emojiSize,
    child: Text.rich(
      span,
      maxLines: widget.maxLines,
      overflow: widget.overflow ?? TextOverflow.clip,
    ),
  );

  @override
  Widget build(BuildContext context) {
    ref.watch(channelsProvider);

    final tree = addTextSpans(parseMarkup(widget.rawText ?? ''));
    final ctx = _context(context);
    final span = buildTextSpan(tree, ctx);
    _syncRelativeTicker(
      ctx.relativeCount == 0
          ? null
          : ctx.countingSeconds
          ? _countdownTick
          : _relativeTick,
    );
    final emojiSize = ctx.largeEmoji
        ? context.neriSize.dimen(NeriDimen.emojiLg)
        : emojiSizeFor(context);

    if (ctx.gradientCount == 0) return _text(span, emojiSize);

    //shaded pass is needed to resolve gradient bounds
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter =
            TextPainter(
                text: TextSpan(style: ctx.baseStyle, children: [span]),
                textDirection: ctx.textDirection,
                textScaler: ctx.textScaler,
                maxLines: widget.maxLines,
                ellipsis: widget.overflow == TextOverflow.ellipsis ? '…' : null,
              )
              ..setPlaceholderDimensions(ctx.placeholderDimensions(emojiSize))
              ..layout(maxWidth: constraints.maxWidth);

        final shaders = gradientShaders(span, painter);
        painter.dispose();

        final shaded = buildTextSpan(tree, _context(context, shaders: shaders));

        return RepaintBoundary(child: _text(shaded, emojiSize));
      },
    );
  }
}
