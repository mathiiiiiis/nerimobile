import 'package:flutter/widgets.dart';

const neriMediumMinWidth = 600.0;
const neriExpandedMinWidth = 1024.0;

const neriHeaderHeightCompact = 48.0;
const neriHeaderHeightRegular = 55.0;

enum NeriWindowClass {
  compact,
  medium,
  expanded;

  bool get usesBottomNav => this == NeriWindowClass.compact;

  bool get usesRail => this != NeriWindowClass.compact;

  bool get isDualPane => this == NeriWindowClass.expanded;

  double get headerHeight => this == NeriWindowClass.compact
      ? neriHeaderHeightCompact
      : neriHeaderHeightRegular;
}

NeriWindowClass windowClassForWidth(double width) {
  if (width >= neriExpandedMinWidth) return NeriWindowClass.expanded;
  if (width >= neriMediumMinWidth) return NeriWindowClass.medium;
  return NeriWindowClass.compact;
}

class NeriWindowScope extends StatelessWidget {
  const NeriWindowScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => NeriWindow(
      windowClass: windowClassForWidth(constraints.maxWidth),
      child: child,
    ),
  );
}

class NeriWindow extends InheritedWidget {
  const NeriWindow({
    super.key,
    required this.windowClass,
    required super.child,
  });

  final NeriWindowClass windowClass;

  static NeriWindowClass of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NeriWindow>()!.windowClass;

  @override
  bool updateShouldNotify(NeriWindow oldWidget) =>
      windowClass != oldWidget.windowClass;
}
