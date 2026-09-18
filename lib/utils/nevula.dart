class Span {
  final int start;
  final int end;

  Span({required this.start, required this.end});
}

sealed class Entity {
  final String type;
  final Span innerSpan;
  final Span outerSpan;
  final List<Entity> entities;
  final Map<String, dynamic> params;

  Entity(this.type, this.innerSpan, this.outerSpan, this.entities, this.params);
}

class TextEntity extends Entity {
  TextEntity(
    Span innerSpan,
    Span outerSpan,
    List<Entity> entities, [
    Map<String, dynamic>? params,
  ]) : super("text", innerSpan, outerSpan, entities, params ?? {});
}

class LinkEntity extends Entity {
  LinkEntity(Span innerSpan, Span outerSpan, List<Entity> entities)
    : super("link", innerSpan, outerSpan, entities, {});
}

class NamedLinkEntity extends Entity {
  NamedLinkEntity(Span innerSpan, Span outerSpan, String url, String name)
    : super("named_link", innerSpan, outerSpan, [], {"url": url, "name": name});
}

class BoldEntity extends Entity {
  BoldEntity(Span innerSpan, Span outerSpan, List<Entity> entities)
    : super("bold", innerSpan, outerSpan, entities, {});
}

class ItalicEntity extends Entity {
  ItalicEntity(Span innerSpan, Span outerSpan, List<Entity> entities)
    : super("italic", innerSpan, outerSpan, entities, {});
}

class SpoilerEntity extends Entity {
  SpoilerEntity(Span innerSpan, Span outerSpan, List<Entity> entities)
    : super("spoiler", innerSpan, outerSpan, entities, {});
}

class UnderlineEntity extends Entity {
  UnderlineEntity(Span innerSpan, Span outerSpan, List<Entity> entities)
    : super("underline", innerSpan, outerSpan, entities, {});
}

class StrikethroughEntity extends Entity {
  StrikethroughEntity(Span innerSpan, Span outerSpan, List<Entity> entities)
    : super("strikethrough", innerSpan, outerSpan, entities, {});
}

class CodeEntity extends Entity {
  CodeEntity(Span innerSpan, Span outerSpan, List<Entity> entities)
    : super("code", innerSpan, outerSpan, entities, {});
}

class EmojiEntity extends Entity {
  EmojiEntity(Span innerSpan, Span outerSpan)
    : super("emoji", innerSpan, outerSpan, [], {});
}

class EmojiNameEntity extends Entity {
  EmojiNameEntity(Span innerSpan, Span outerSpan)
    : super("emoji_name", innerSpan, outerSpan, [], {});
}

class CodeblockEntity extends Entity {
  CodeblockEntity(
    Span innerSpan,
    Span outerSpan,
    List<Entity> entities,
    String? lang,
  ) : super("codeblock", innerSpan, outerSpan, entities, {"lang": lang});
}

class HeadingEntity extends Entity {
  HeadingEntity(
    Span innerSpan,
    Span outerSpan,
    List<Entity> entities,
    int level,
  ) : super("heading", innerSpan, outerSpan, entities, {"level": level});
}

class BlockquoteEntity extends Entity {
  BlockquoteEntity(
    Span innerSpan,
    Span outerSpan,
    List<Entity> entities, {
    String? borderColor,
  }) : super("blockquote", innerSpan, outerSpan, entities, {
         "borderColor": borderColor,
       });
}

class ColorEntity extends Entity {
  ColorEntity(
    Span innerSpan,
    Span outerSpan,
    List<Entity> entities,
    String color,
  ) : super("color", innerSpan, outerSpan, entities, {"color": color});
}

class CheckboxEntity extends Entity {
  CheckboxEntity(Span innerSpan, Span outerSpan, bool checked)
    : super("checkbox", innerSpan, outerSpan, [], {"checked": checked});
}

class CustomEntity extends Entity {
  CustomEntity(
    Span innerSpan,
    Span outerSpan,
    List<Entity> entities,
    String customType,
  ) : super("custom", innerSpan, outerSpan, entities, {"type": customType});
}

class Marker {
  final String type;
  final Span span;
  final dynamic data;

  Marker({required this.type, required this.span, this.data});
}

bool containsSpan(Span largeSpan, Span smallSpan) {
  return largeSpan.start <= smallSpan.start && smallSpan.end <= largeSpan.end;
}

(List<T>, List<T>) partition<T>(List<T> list, bool Function(T item) filter) {
  List<T> pass = [];
  List<T> fail = [];
  for (var item in list) {
    if (filter(item)) {
      pass.add(item);
    } else {
      fail.add(item);
    }
  }
  return (pass, fail);
}

int findLastIndex<T>(List<T> list, bool Function(T item) predicate) {
  for (int i = list.length - 1; i >= 0; i--) {
    if (predicate(list[i])) return i;
  }
  return -1;
}

final RegExp emojiRegex = RegExp(
  r'(?:(?:(?:(?:(?:\p{Emoji})(?:\u{FE0F}))|(?:(?:\p{Emoji_Modifier_Base})(?:\p{Emoji_Modifier}))|(?:\p{Emoji}))(?:[\u{E0020}-\u{E007E}]+)(?:\u{E007F}))|(?:(?:(?:(?:\p{Emoji_Modifier_Base})(?:\p{Emoji_Modifier}))|(?:(?:\p{Emoji})(?:\u{FE0F}))|(?:\p{Emoji}))(?:(?:\u{200d})(?:(?:(?:\p{Emoji_Modifier_Base})(?:\p{Emoji_Modifier}))|(?:(?:\p{Emoji})(?:\u{FE0F}))|(?:\p{Emoji})))+)|(?:(?:(?:\p{Regional_Indicator})(?:\p{Regional_Indicator}))|(?:(?:\p{Emoji_Modifier_Base})(?:\p{Emoji_Modifier}))|(?:[0-9#*]\u{FE0F}\u{20E3})|(?:(?:\p{Emoji})(?:\u{FE0F}))))|\p{Emoji_Presentation}|\p{Extended_Pictographic}',
  unicode: true,
);

final Map<String, String> tokenParts = {
  'escape': r'\\[\\*/_~`\[\]]',
  'bold': r'\*\*',
  'underline': r'__',
  'italic': r'(?:\*|\/\/|(?<!\w)_|_(?!\w))',
  'strikethrough': r'~~',
  'codeblock': r'```',
  'code': r'`?`',
  'spoiler': r'\|\|',
  'checkbox': r'-\[(?:x| )\]',
  'named_link':
      r'\[(?:.|[\s*\p{L}\p{N}\u{21}-\u{2F}_]+)\]\(https?://\S+\.[\p{Alphabetic}\d/\\#?=+&%@!;:._~-]+\)',
  'link': r'https?://\S+\.[\p{Alphabetic}\d/\\#?=+&%@!;:._~-]+',
  'link_contained': r'<https?://\S+\.[\p{Alphabetic}\d/\\#?=+&%@!;:._~-]+>',
  'emoji': emojiRegex.pattern,
  'color': r'\[#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6}|reset)\]',
  'custom_start': r'\[(?:[^\]\s:]+):',
  'custom_end': r'\]',
  'emoji_name': r':\w+:',
  'newline': r'\r?\n',
  'egg': r'§(?:[0-9a-fr])',
};

final Map<String, String> eggs = {
  "§0": "#000",
  "§1": "#00A",
  "§2": "#0A0",
  "§3": "#0AA",
  "§4": "#A00",
  "§5": "#A0A",
  "§6": "#FA0",
  "§7": "#AAA",
  "§8": "#555",
  "§9": "#55F",
  "§a": "#5F5",
  "§b": "#5FF",
  "§c": "#F55",
  "§d": "#F5F",
  "§e": "#FF5",
  "§f": "#FFF",
  "§r": "#reset",
};

final List<String> types = tokenParts.keys.toList();
final RegExp globalTokenRegex = RegExp(
  tokenParts.values.map((pattern) => '($pattern)').join('|'),
  unicode: true,
);

String getTokenType(RegExpMatch match) {
  final String text = match.group(0)!;
  for (var entry in tokenParts.entries) {
    if (RegExp('^${entry.value}\$', unicode: true).hasMatch(text)) {
      return entry.key;
    }
  }
  return "text";
}

List<Entity> _escapesBetween(List<RegExpMatch> tokens, int from, int to) => [
  for (final token in tokens.sublist(from, to))
    if (getTokenType(token) == "escape")
      TextEntity(
        Span(start: token.start + 1, end: token.end),
        Span(start: token.start, end: token.end),
        [],
      ),
];

Entity parseMarkup(String text) {
  List<Marker> markers = [];
  List<Entity> entities = [];
  final tokens = globalTokenRegex.allMatches(text).toList();
  final headingRegex = RegExp(r'^(#|##|###|####|#####|######) ');

  bool checkColor(Span span) {
    final markerIndex = findLastIndex(
      markers,
      (m) =>
          m.type == "color" &&
          m.span.start >= span.start &&
          span.end >= m.span.end,
    );

    if (markerIndex >= 0) {
      final marker = markers[markerIndex];
      final innerSpan = Span(start: marker.span.end, end: span.end);
      final outerSpan = Span(start: marker.span.start, end: span.end);

      var (inner, remaining) = partition(
        entities,
        (e) => containsSpan(outerSpan, e.innerSpan),
      );

      markers.removeRange(markerIndex, markers.length);
      entities = remaining;

      checkColor(Span(start: span.start, end: outerSpan.start));

      entities.add(ColorEntity(innerSpan, outerSpan, inner, marker.data));
      return true;
    }
    return false;
  }

  void parseLine(Span indice) {
    final blockQuoteMarkerIndex = markers.indexWhere(
      (m) => m.type == "blockquote",
    );
    final headingMarkerIndex = markers.indexWhere((m) => m.type == "heading");

    if (blockQuoteMarkerIndex >= 0) {
      final marker = markers[blockQuoteMarkerIndex];
      final innerSpan = Span(start: marker.span.end, end: indice.start);
      final outerSpan = Span(start: marker.span.start, end: indice.start);

      checkColor(innerSpan);
      var (inner, remaining) = partition(
        entities,
        (e) => containsSpan(outerSpan, e.outerSpan),
      );

      markers.removeRange(blockQuoteMarkerIndex, markers.length);
      entities = remaining;
      entities.add(BlockquoteEntity(innerSpan, outerSpan, inner));
    }

    if (headingMarkerIndex >= 0) {
      final marker = markers[headingMarkerIndex];
      final innerSpan = Span(start: marker.span.end, end: indice.start);
      final outerSpan = Span(start: marker.span.start, end: indice.start);

      checkColor(innerSpan);
      var (inner, remaining) = partition(
        entities,
        (e) => containsSpan(outerSpan, e.outerSpan),
      );

      markers.removeRange(headingMarkerIndex, markers.length);
      entities = remaining;
      entities.add(HeadingEntity(innerSpan, outerSpan, inner, marker.data));
    }

    if (text.substring(indice.end).startsWith("> ")) {
      checkColor(
        Span(
          start: entities.isNotEmpty ? entities.last.outerSpan.end : 0,
          end: indice.end - 1,
        ),
      );
      markers.add(
        Marker(
          type: "blockquote",
          span: Span(start: indice.end, end: indice.end + 2),
        ),
      );
    }

    final headingMatch = headingRegex.firstMatch(text.substring(indice.end));
    if (headingMatch != null) {
      checkColor(
        Span(
          start: entities.isNotEmpty ? entities.last.outerSpan.end : 0,
          end: indice.end - 1,
        ),
      );
      markers.add(
        Marker(
          type: "heading",
          span: Span(
            start: indice.end,
            end: indice.end + headingMatch.group(0)!.length,
          ),
          data: headingMatch.group(1)?.length,
        ),
      );
    }
  }

  parseLine(Span(start: 0, end: 0));

  for (int pos = 0; pos < tokens.length; pos++) {
    final token = tokens[pos];
    int groupIndex = -1;
    for (int i = 1; i <= token.groupCount; i++) {
      if (token.group(i) != null) {
        groupIndex = i - 1;
        break;
      }
    }

    final type = types[groupIndex];
    final indice = Span(start: token.start, end: token.end);

    switch (type) {
      case "newline":
        parseLine(indice);
        entities.add(TextEntity(indice, indice, []));
        break;
      case "emoji_name":
        entities.add(
          EmojiNameEntity(
            Span(start: indice.start + 1, end: indice.end - 1),
            indice,
          ),
        );
        break;
      case "emoji":
        entities.add(EmojiEntity(indice, indice));
        break;
      case "bold":
      case "italic":
      case "spoiler":
      case "underline":
      case "strikethrough":
        final data = token.group(0);
        final markerIndex = markers.indexWhere(
          (m) => m.type == type && m.data == data,
        );
        if (markerIndex >= 0) {
          final marker = markers[markerIndex];
          final innerSpan = Span(start: marker.span.end, end: indice.start);
          final outerSpan = Span(start: marker.span.start, end: indice.end);

          checkColor(innerSpan);
          var (inner, remaining) = partition(
            entities,
            (e) => containsSpan(outerSpan, e.innerSpan),
          );

          markers.removeRange(markerIndex, markers.length);
          entities = remaining;

          if (type == "bold") {
            entities.add(BoldEntity(innerSpan, outerSpan, inner));
          }
          if (type == "italic") {
            entities.add(ItalicEntity(innerSpan, outerSpan, inner));
          }
          if (type == "spoiler") {
            entities.add(SpoilerEntity(innerSpan, outerSpan, inner));
          }
          if (type == "underline") {
            entities.add(UnderlineEntity(innerSpan, outerSpan, inner));
          }
          if (type == "strikethrough") {
            entities.add(StrikethroughEntity(innerSpan, outerSpan, inner));
          }
        } else {
          markers.add(Marker(type: type, span: indice, data: data));
        }
        break;
      case "code":
        final markerIndex = tokens.indexWhere(
          (t) => getTokenType(t) == "code" && t.group(0) == token.group(0),
          pos + 1,
        );
        if (markerIndex >= 0) {
          final endToken = tokens[markerIndex];
          final endIndice = Span(start: endToken.start, end: endToken.end);
          checkColor(Span(start: indice.start, end: indice.start));
          entities.add(
            CodeEntity(
              Span(start: indice.end, end: endIndice.start),
              Span(start: indice.start, end: endIndice.end),
              _escapesBetween(tokens, pos, markerIndex),
            ),
          );
          pos = markerIndex;
        }
        break;
      case "codeblock":
        final markerIndex = tokens.indexWhere(
          (t) => getTokenType(t) == "codeblock",
          pos + 1,
        );
        if (markerIndex != -1) {
          final endToken = tokens[markerIndex];
          final endIndice = Span(start: endToken.start, end: endToken.end);
          final langRegex = RegExp(r'\w*\r?\n');
          final langMatch = langRegex.firstMatch(text.substring(indice.end));
          final lang = langMatch?.group(0)?.trim();

          checkColor(
            Span(
              start: entities.isNotEmpty ? entities.last.outerSpan.end : 0,
              end: indice.start,
            ),
          );
          entities.add(
            CodeblockEntity(
              Span(
                start: indice.end + (langMatch?.group(0)?.length ?? 0),
                end: endIndice.start,
              ),
              Span(start: indice.start, end: endIndice.end),
              _escapesBetween(tokens, pos, markerIndex),
              lang,
            ),
          );
          pos = markerIndex;
        }
        break;
      case "checkbox":
        final checked = token.group(0)!.contains('x');
        entities.add(CheckboxEntity(indice, indice, checked));
        break;
      case "egg":
      case "color":
        String? color = type == "color"
            ? text.substring(indice.start + 1, indice.end - 1)
            : eggs[text.substring(indice.start, indice.end)];
        if (color == "#reset" || color == "reset") {
          color = "reset";
          checkColor(indice);
        }
        markers.add(Marker(type: "color", span: indice, data: color));
        break;
      case "custom_start":
        int markerIndex = -1;
        for (int i = pos + 1; i < tokens.length; i++) {
          if (getTokenType(tokens[i]) == "custom_end") {
            markerIndex = i;
            break;
          }
        }

        if (markerIndex >= 0) {
          final endToken = tokens[markerIndex];
          final endIndice = Span(start: endToken.start, end: endToken.end);

          final String customType = token
              .group(0)!
              .substring(1, token.group(0)!.length - 1);

          checkColor(
            Span(
              start: entities.isNotEmpty ? entities.last.outerSpan.end : 0,
              end: indice.start,
            ),
          );

          entities.add(
            CustomEntity(
              Span(start: indice.end, end: endIndice.start),
              Span(start: indice.start, end: endIndice.end),
              [],
              customType,
            ),
          );
          pos = markerIndex;
        }
        break;
      case "link_contained":
        entities.add(
          LinkEntity(
            Span(start: indice.start + 1, end: indice.end - 1),
            indice,
            [],
          ),
        );
        break;
      case "named_link":
        final linkRegex = RegExp(r'\[(.*?)\]\((.*?)\)');
        final match = linkRegex.firstMatch(
          text.substring(indice.start, indice.end),
        );
        entities.add(
          NamedLinkEntity(
            indice,
            indice,
            match?.group(2) ?? "",
            match?.group(1) ?? "",
          ),
        );
        break;
      case "link":
        entities.add(LinkEntity(indice, indice, []));
        break;
      case "escape":
        entities.add(
          TextEntity(
            Span(start: indice.start + 1, end: indice.end),
            indice,
            [],
          ),
        );
        break;
    }
  }

  parseLine(Span(start: text.length, end: text.length));
  checkColor(
    Span(
      start: entities.isNotEmpty ? entities.last.outerSpan.end : 0,
      end: text.length,
    ),
  );
  if (entities.isNotEmpty) {
    checkColor(Span(start: 0, end: text.length));
  }

  return TextEntity(
    Span(start: 0, end: text.length),
    Span(start: 0, end: text.length),
    entities,
  );
}

Entity addTextSpans(Entity entity) {
  if (entity.entities.isEmpty && entity is TextEntity) {
    return entity;
  }

  List<Entity> newEntities = [];
  for (int i = 0; i < entity.entities.length; i++) {
    final e = entity.entities[i];
    final textSpan = Span(
      start: newEntities.isNotEmpty
          ? newEntities.last.outerSpan.end
          : entity.innerSpan.start,
      end: e.outerSpan.start,
    );

    if (textSpan.end > textSpan.start) {
      newEntities.add(TextEntity(textSpan, textSpan, []));
    }
    newEntities.add(addTextSpans(e));
  }

  final endingTextSpan = Span(
    start: entity.entities.isNotEmpty
        ? entity.entities.last.outerSpan.end
        : entity.innerSpan.start,
    end: entity.innerSpan.end,
  );

  if (endingTextSpan.end > endingTextSpan.start) {
    newEntities.add(TextEntity(endingTextSpan, endingTextSpan, []));
  }

  return switch (entity) {
    TextEntity e => TextEntity(e.innerSpan, e.outerSpan, newEntities, e.params),
    LinkEntity e => LinkEntity(e.innerSpan, e.outerSpan, newEntities),
    NamedLinkEntity e => NamedLinkEntity(
      e.innerSpan,
      e.outerSpan,
      e.params['url'],
      e.params['name'],
    ),
    BoldEntity e => BoldEntity(e.innerSpan, e.outerSpan, newEntities),
    ItalicEntity e => ItalicEntity(e.innerSpan, e.outerSpan, newEntities),
    SpoilerEntity e => SpoilerEntity(e.innerSpan, e.outerSpan, newEntities),
    UnderlineEntity e => UnderlineEntity(e.innerSpan, e.outerSpan, newEntities),
    StrikethroughEntity e => StrikethroughEntity(
      e.innerSpan,
      e.outerSpan,
      newEntities,
    ),
    CodeEntity e => CodeEntity(e.innerSpan, e.outerSpan, newEntities),
    EmojiEntity e => EmojiEntity(e.innerSpan, e.outerSpan),
    EmojiNameEntity e => EmojiNameEntity(e.innerSpan, e.outerSpan),
    CodeblockEntity e => CodeblockEntity(
      e.innerSpan,
      e.outerSpan,
      newEntities,
      e.params['lang'],
    ),
    HeadingEntity e => HeadingEntity(
      e.innerSpan,
      e.outerSpan,
      newEntities,
      e.params['level'],
    ),
    BlockquoteEntity e => BlockquoteEntity(
      e.innerSpan,
      e.outerSpan,
      newEntities,
      borderColor: e.params['borderColor'],
    ),
    ColorEntity e => ColorEntity(
      e.innerSpan,
      e.outerSpan,
      newEntities,
      e.params['color'],
    ),
    CheckboxEntity e => CheckboxEntity(
      e.innerSpan,
      e.outerSpan,
      e.params['checked'],
    ),
    CustomEntity e => CustomEntity(
      e.innerSpan,
      e.outerSpan,
      newEntities,
      e.params['type'],
    ),
  };
}
