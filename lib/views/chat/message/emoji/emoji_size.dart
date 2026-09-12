import 'package:flutter/widgets.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';

//emoji size follows text line height
double emojiSizeFor(BuildContext context) {
  final style = DefaultTextStyle.of(context).style;
  final fontSize = style.fontSize;
  if (fontSize == null) return context.neriSize.dimen(NeriDimen.emojiSm);

  return fontSize * (style.height ?? 1);
}

class EmojiSizeScope extends InheritedWidget {
  const EmojiSizeScope({super.key, required this.size, required super.child});

  final double size;

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EmojiSizeScope>()?.size ??
      context.neriSize.dimen(NeriDimen.emojiSm);

  @override
  bool updateShouldNotify(EmojiSizeScope oldWidget) => size != oldWidget.size;
}
