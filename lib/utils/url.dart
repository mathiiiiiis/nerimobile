bool isValidUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.hasAbsolutePath && uri.hasScheme;
  } catch (e) {
    return false;
  }
}

String filenameFromPath(String path) {
  final name = path.split('/').last;
  try {
    return Uri.decodeComponent(name);
  } on ArgumentError {
    return name;
  }
}
