import 'package:flutter/widgets.dart';

const emojiSize = 20.0;
const largeEmojiSize = 48.0;

class EmojiSizeScope extends InheritedWidget {
  const EmojiSizeScope({super.key, required this.size, required super.child});

  final double size;

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EmojiSizeScope>()?.size ??
      emojiSize;

  @override
  bool updateShouldNotify(EmojiSizeScope oldWidget) => size != oldWidget.size;
}
