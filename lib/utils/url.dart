import 'package:url_launcher/url_launcher.dart';

Future<void> openExternal(String url) =>
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

String withScheme(String url) =>
    url.startsWith('http://') || url.startsWith('https://')
    ? url
    : 'https://$url';

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
