import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/dimens.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';

const _open = Duration(milliseconds: 200);
const _buttonOpacity = 0.4;
const _dismissDistance = 120.0;
const _dismissVelocity = 700.9;

typedef OptionsCallback =
    void Function(BuildContext context, WidgetRef ref, String url);

Future<void> openFullscreen(BuildContext context, WidgetBuilder builder) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: _open,
      reverseTransitionDuration: _open,
      pageBuilder: (context, _, _) => builder(context),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class FullscreenShell extends StatefulWidget {
  const FullscreenShell({
    super.key,
    required this.child,
    this.onOptions,
    this.bottom,
  });

  final Widget child;
  final VoidCallback? onOptions;
  final Widget? bottom;

  @override
  State<FullscreenShell> createState() => _FullscreenShellState();
}

class _FullscreenShellState extends State<FullscreenShell> {
  bool _controls = true;
  double _drag = 0;

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _controls = !_controls);
    SystemChrome.setEnabledSystemUIMode(
      _controls ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() => _drag = (_drag + details.primaryDelta!).clamp(0.0, 4000.0));
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_drag > _dismissDistance || velocity > _dismissVelocity) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _drag = 0);
  }

  @override
  Widget build(BuildContext context) {
    final opacity = (1 - _drag / (_dismissDistance * 3)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: opacity),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: Transform.translate(
          offset: Offset(0, _drag),
          child: Stack(
            children: [
              Center(child: widget.child),
              _Controls(
                visible: _controls,
                onOptions: widget.onOptions,
                bottom: widget.bottom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.visible, this.onOptions, this.bottom});

  final bool visible;
  final VoidCallback? onOptions;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final sizing = context.neriSize;

    return IgnorePointer(
      ignoring: !visible,
      child: Opacity(
        opacity: visible ? 1 : 0,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                sizing.space(NeriSpacingRole.md),
                sizing.space(NeriSpacingRole.md) +
                    MediaQuery.viewPaddingOf(context).top,
                sizing.space(NeriSpacingRole.md),
                sizing.space(NeriSpacingRole.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ControlButton(
                    icon: Symbols.close_rounded,
                    size: sizing.dimen(NeriDimen.avatarSm),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  if (onOptions case final onOptions?)
                    ControlButton(
                      icon: Symbols.more_vert_rounded,
                      size: sizing.dimen(NeriDimen.avatarSm),
                      onTap: onOptions,
                    ),
                ],
              ),
            ),
            if (bottom case final bottom?)
              Align(alignment: Alignment.bottomCenter, child: bottom),
          ],
        ),
      ),
    );
  }
}

class ControlButton extends StatelessWidget {
  const ControlButton({
    super.key,
    required this.icon,
    required this.size,
    required this.onTap,
    this.background = true,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final bool background;

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background
              ? colors[NeriToken.scrim].withValues(alpha: _buttonOpacity)
              : null,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          fill: 1,
          size: size * 0.55,
          color: colors[NeriToken.text],
        ),
      ),
    );
  }
}
