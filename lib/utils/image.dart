import 'package:nerimobile/config.dart';

String buildImageUrl(
  String url, {
  int? size,
  bool? animate,
  bool? forceIsAnimated,
}) {
  final uri = Uri.parse("$cdnUrl$url");

  final endsWithGif = uri.path.endsWith('.gif');
  final endsWithHashA = uri.fragment == 'a';
  final isAnimated = endsWithGif || endsWithHashA || forceIsAnimated == true;

  if (!isAnimated && size == null) return uri.toString();

  final newParams = Map<String, String>.from(uri.queryParameters);

  if (isAnimated && animate == null || animate == false) {
    newParams['type'] = 'webp';
  }

  if (size != null) newParams['size'] = size.toString();

  return uri.replace(queryParameters: newParams).toString();
}

({double width, double height}) constrainDimensions({
  required double width,
  required double height,
  required double maxWidth,
  required double maxHeight,
}) {
  final ratio = width / height;

  if (width > maxWidth) {
    width = maxWidth;
    height = width / ratio;
  }
  if (height > maxHeight) {
    height = maxHeight;
    width = height * ratio;
  }

  return (width: width, height: height);
}
