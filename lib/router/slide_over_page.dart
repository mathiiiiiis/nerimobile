import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const _dragMinDistance = 12.0;
const _flingVelocity = 700.0;
const _transition = Duration(milliseconds: 200);

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
    _dragging = false;
    if (pop) {
      navigator!.pop();
    } else {
      controller!.animateTo(1, duration: _transition, curve: Curves.easeOut);
    }
    navigator!.didStopUserGesture();
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

  bool get _enabled =>
      widget.route.isCurrent &&
      !widget.route.navigator!.userGestureInProgress &&
      widget.route.animation?.status == AnimationStatus.completed;

  void _onStart(DragStartDetails details) {
    if (!_enabled) return;
    widget.route.dragStart();
  }

  void _onUpdate(DragUpdateDetails details) {
    if (!widget.route._dragging) return;
    widget.route.dragUpdate(details.primaryDelta! / _width);
  }

  void _onEnd(DragEndDetails details) {
    if (!widget.route._dragging) return;
    final velocity = details.primaryVelocity ?? 0;

    final shouldPop = velocity > _flingVelocity
        ? true
        : velocity < -_flingVelocity
        ? false
        : widget.route.dragProgress < 0.5;

    widget.route.dragEnd(pop: shouldPop);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        return RawGestureDetector(
          behavior: HitTestBehavior.translucent,
          gestures: {
            _BackDragRecognizer:
                GestureRecognizerFactoryWithHandlers<_BackDragRecognizer>(
                  _BackDragRecognizer.new,
                  (recognizer) => recognizer
                    ..onStart = _onStart
                    ..onUpdate = _onUpdate
                    ..onEnd = _onEnd,
                ),
          },
          child: widget.child,
        );
      },
    );
  }
}

class _BackDragRecognizer extends HorizontalDragGestureRecognizer {
  final _origins = <int, Offset>{};

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _origins[event.pointer] = event.position;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    final origin = _origins[event.pointer];

    //let vertical and leftward drag win
    if (event is PointerMoveEvent && origin != null) {
      final delta = event.position.dx - origin.dx;
      if (delta < _dragMinDistance) {
        if (delta < -_dragMinDistance) {
          _origins.remove(event.pointer);
          stopTrackingPointer(event.pointer);
        }
        return;
      }
    }

    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _origins.remove(event.pointer);
    }

    super.handleEvent(event);
  }
}
