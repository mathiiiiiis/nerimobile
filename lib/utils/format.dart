String formatFileSize(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var unit = 0;

  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit += 1;
  }

  return '${size.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
}

String formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String formatExpiry(int expiresAt) {
  final remaining = expiresAt - DateTime.now().millisecondsSinceEpoch;
  if (remaining <= 0) return 'Expired'; //TODO: add l10n

  final minutes = remaining ~/ Duration.millisecondsPerMinute;
  if (minutes < 60) return 'Expires in ${minutes}m'; //TODO: add l10n

  return 'Expires in ${minutes ~/ 60}h'; //TODO: add l10n
}
