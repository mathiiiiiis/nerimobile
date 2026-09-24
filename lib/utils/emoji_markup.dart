import 'package:nerimobile/models/custom_emoji.dart';
import 'package:nerimobile/utils/emoji_shortcodes.dart';

final _shortcode = RegExp(r':[\w+-]+:');

//convert shortcodes to markup before sending
String replaceShortcodes(String content, Map<String, CustomEmoji> customs) =>
    content.replaceAllMapped(_shortcode, (match) {
      final shortcode = match[0]!;
      final name = shortcode.substring(1, shortcode.length - 1);

      final unicode = emojiShortcodes[name];
      if (unicode != null) return unicode;

      final custom = customs[name];
      if (custom == null) return shortcode;

      return '[${custom.type}:${custom.id}:$name]';
    });
