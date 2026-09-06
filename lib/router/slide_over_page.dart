import 'package:flutter/material.dart';

const _dragMinDistance = 12.0;
const _flingVelocity = 700.0;
const _dismissAt = 0.75;
const _transition = Duration(milliseconds: 300);

class StaticPage<T> extends Page<T> {
  const StaticPage({required this.child, super.key, super.name});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => _StaticRoute<T>(this);
}

class _StaticRoute<T> extends PageRoute<T> {
  _StaticRoute(StaticPage<T> page) : super(settings: page);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, _) =>
      (settings as StaticPage<T>).child;

  @override
  Widget buildTransitions(BuildContext context, _, _, Widget child) => child;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;
}

class SlideOverPage<T> extends Page<T> {
  const SlideOverPage({required this.child, super.key, super.name});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => SlideOverRoute<T>(this);
}

class SlideOverRoute<T> extends PageRoute<T> {
  SlideOverRoute(SlideOverPage<T> page) : super(settings: page);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, _) =>
      _SlideOverGestureDetector(
        route: this,
        child: (settings as SlideOverPage<T>).child,
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curve = _dragging
        ? animation
        : CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn);

    return SlideTransition(
      position: Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(curve),
      child: child,
    );
  }

  bool _dragging = false;

  void dragStart() {
    _dragging = true;
    navigator!.didStartUserGesture();
  }

  void dragUpdate(double fraction) => controller!.value -= fraction;

  void dragEnd({required bool pop}) {
    final controller = this.controller!;

    if (pop) {
      navigator!.pop();
      if (controller.isAnimating) {
        controller.animateBack(
          0,
          duration: _transition * controller.value,
          curve: Curves.easeOut,
        );
      }
    } else {
      controller.animateTo(
        1,
        duration: _transition * (1 - controller.value),
        curve: Curves.easeOut,
      );
    }

    if (!controller.isAnimating) {
      _endGesture();
      return;
    }

    void onStatus(AnimationStatus status) {
      controller.removeStatusListener(onStatus);
      _endGesture();
    }

    controller.addStatusListener(onStatus);
  }

  void _endGesture() {
    if (!_dragging) return;
    _dragging = false;
    if (navigator?.userGestureInProgress ?? false) {
      navigator!.didStopUserGesture();
    }
  }

  double get dragProgress => controller!.value;

  @override
  Duration get transitionDuration => _transition;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;
}

class _SlideOverGestureDetector extends StatefulWidget {
  const _SlideOverGestureDetector({required this.route, required this.child});

  final SlideOverRoute route;
  final Widget child;

  @override
  State<_SlideOverGestureDetector> createState() =>
      _SlideOverGestureDetectorState();
}

class _SlideOverGestureDetectorState extends State<_SlideOverGestureDetector> {
  double _width = 0;
  double _travelled = 0;

  bool get _enabled =>
      widget.route.isCurrent &&
      !widget.route.navigator!.userGestureInProgress &&
      widget.route.animation?.status == AnimationStatus.completed;

  void _onStart(DragStartDetails details) => _travelled = 0;

  void _onUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;

    if (!widget.route._dragging) {
      _travelled += delta;
      if (_travelled < _dragMinDistance || !_enabled) return;
      widget.route.dragStart();
    }

    widget.route.dragUpdate(details.primaryDelta! / _width);
  }

  void _onEnd(DragEndDetails details) {
    if (!widget.route._dragging) return;
    final velocity = details.primaryVelocity ?? 0;

    final shouldPop = velocity > _flingVelocity
        ? true
        : velocity < -_flingVelocity
        ? false
        : widget.route.dragProgress < _dismissAt;

    widget.route.dragEnd(pop: shouldPop);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: _onStart,
          onHorizontalDragUpdate: _onUpdate,
          onHorizontalDragEnd: _onEnd,
          child: widget.child,
        );
      },
    );
  }
}
