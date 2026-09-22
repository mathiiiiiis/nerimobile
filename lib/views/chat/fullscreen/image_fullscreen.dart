import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/sizing/radius.dart';
import 'package:nerimobile/views/chat/fullscreen/fullscreen_shell.dart';

const _doubleTapScale = 2.5;
const _maxScale = 5.0;
const _zoom = Duration(milliseconds: 250);
const _morph = Duration(milliseconds: 300);

Future<void> openImageFullscreen(
  BuildContext context,
  ImageProvider image, {
  required Rect from,
  String? url,
  OptionsCallback? onOptions,
}) => openFullscreen(
  context,
  (_) =>
      ImageFullscreen(image: image, from: from, url: url, onOptions: onOptions),
  fade: false,
  duration: _morph,
);

class ImageFullscreen extends ConsumerStatefulWidget {
  const ImageFullscreen({
    super.key,
    required this.image,
    required this.from,
    this.url,
    this.onOptions,
  });

  final ImageProvider image;
  final Rect from;
  final String? url;
  final OptionsCallback? onOptions;

  @override
  ConsumerState<ImageFullscreen> createState() => _ImageFulscreenState();
}

class _ImageFulscreenState extends ConsumerState<ImageFullscreen>
    with SingleTickerProviderStateMixin {
  final _transform = TransformationController();
  late final _animation = AnimationController(vsync: this, duration: _zoom)
    ..addListener(() => _transform.value = _tween.value);
  late Animation<Matrix4> _tween;
  Offset _tap = Offset.zero;
  bool _zoomed = false;
  late Size _imageSize = widget.from.size;
  ImageStream? _stream;
  late final _listener = ImageStreamListener((info, _) {
    final size = Size(
      info.image.width.toDouble(),
      info.image.height.toDouble(),
    );
    if (size != _imageSize && mounted) setState(() => _imageSize = size);
  });

  @override
  void initState() {
    super.initState();
    _transform.addListener(_onTransform);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stream?.removeListener(_listener);
    _stream = widget.image.resolve(createLocalImageConfiguration(context))
      ..addListener(_listener);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _animation.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _onTransform() {
    final zoomed =
        _transform.value.getMaxScaleOnAxis() > 1 + precisionErrorTolerance;
    if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
  }

  void _toggleZoom() {
    final shift = _tap * (1 - _doubleTapScale);
    final target = _zoomed
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(shift.dx, shift.dy, 0, 1)
            ..scaleByDouble(_doubleTapScale, _doubleTapScale, 1, 1));

    _tween = Matrix4Tween(
      begin: _transform.value,
      end: target,
    ).animate(CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic));
    _animation.forward(from: 0);
  }

  Widget _morphing(BuildContext context, double t) {
    final screen = Offset.zero & MediaQuery.sizeOf(context);
    final from = widget.from.translate(0, -FullscreenShell.dragOf(context));
    final fitted = applyBoxFit(BoxFit.contain, _imageSize, screen.size);
    final to = Alignment.center.inscribe(fitted.destination, screen);
    final radius = context.neriSize.radius(NeriRadiusRole.image) * (1 - t);

    return Stack(
      children: [
        Positioned.fromRect(
          rect: Rect.lerp(from, to, t)!,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image(image: widget.image, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final onOptions = widget.onOptions;
    final url = widget.url;
    final route = ModalRoute.of(context)!.animation!;

    return FullscreenShell(
      reveal: route,
      dismissible: !_zoomed,
      onOptions: onOptions == null || url == null
          ? null
          : () => onOptions(context, ref, url),
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: route,
          builder: (context, viewer) => route.isCompleted
              ? viewer!
              : _morphing(
                  context,
                  Curves.easeInOutCubic.transform(route.value),
                ),
          child: GestureDetector(
            onDoubleTapDown: (details) => _tap = details.localPosition,
            onDoubleTap: _toggleZoom,
            child: InteractiveViewer(
              transformationController: _transform,
              maxScale: _maxScale,
              panEnabled: _zoomed,
              onInteractionStart: (_) => _animation.stop(),
              child: Image(image: widget.image, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
