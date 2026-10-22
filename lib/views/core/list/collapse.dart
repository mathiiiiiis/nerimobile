import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

const collapseMotion = Duration(milliseconds: 200);

//only animate a screenful of rows
int revealLimit(BuildContext context, double rowExtent) =>
    (MediaQuery.sizeOf(context).height / rowExtent).ceil();

//keeps closing rows mounted till reveal shrank
mixin CollapseSettling<T extends StatefulWidget> on State<T> {
  final _settling = <String, bool>{};
  final _settleTimers = <String, Timer>{};

  //true during open, false while close
  bool? settling(String key) => _settling[key];

  void settle(String key, {required bool opening}) {
    _settleTimers[key]?.cancel();
    _settleTimers[key] = Timer(collapseMotion, () {
      if (mounted) setState(() => _settling.remove(key));
    });
    setState(() => _settling[key] = opening);
  }

  @override
  void dispose() {
    for (final timer in _settleTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}

class CollapseReveal extends StatelessWidget {
  const CollapseReveal({
    super.key,
    required this.open,
    required this.appear,
    required this.child,
  });

  final bool open;
  final bool appear;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: appear ? 0 : 1, end: open ? 1 : 0),
      duration: collapseMotion,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: value,
          child: Opacity(opacity: value, child: child),
        ),
      ),
      child: child,
    );
  }
}

class CollapseChevron extends StatelessWidget {
  const CollapseChevron({
    super.key,
    required this.collapsed,
    required this.size,
    this.color,
  });

  final bool collapsed;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: collapsed ? -0.25 : 0,
      duration: collapseMotion,
      child: Icon(
        Symbols.keyboard_arrow_down_rounded,
        size: size,
        color: color,
      ),
    );
  }
}
