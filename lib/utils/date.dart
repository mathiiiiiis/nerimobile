import 'package:timezone/timezone.dart' as tz;

//nerimiy uses +HHMM offsets
final _offsetPattern = RegExp(r'^([+-])(\d{2})(\d{2})$');

String? formatZoneTime(String zone) {
  final offset = _offsetPattern.firstMatch(zone);

  if (offset != null) {
    final shift = Duration(
      hours: int.parse(offset.group(2)!),
      minutes: int.parse(offset.group(3)!),
    );
    final now = DateTime.now().toUtc();
    return _clock(
      offset.group(1) == '-' ? now.subtract(shift) : now.add(shift),
    );
  }

  try {
    return _clock(tz.TZDateTime.now(tz.getLocation(zone)));
  } catch (e) {
    return null;
  }
}

String _clock(DateTime time) => [
  time.hour,
  time.minute,
  time.second,
].map((part) => part.toString().padLeft(2, '0')).join(':');

const _relativeSteps = [
  (60.0, 'second'),
  (60.0, 'minute'),
  (24.0, 'hour'),
  (7.0, 'day'),
  (4.35, 'week'),
  (12.0, 'month'),
];

String formatRelative(int milliseconds) {
  final target = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  final difference = target.difference(DateTime.now());
  final ahead = !difference.isNegative;

  //TODO: add l10n
  var value = difference.inMilliseconds.abs() / 1000;
  if (value.round() < 1) return 'now';

  var unit = 'year';
  for (final (limit, name) in _relativeSteps) {
    if (value.round() < limit) {
      unit = name;
      break;
    }
    value /= limit;
  }

  final amount = value.round();
  final plural = amount == 1 ? unit : '${unit}s';

  return ahead ? 'in $amount $plural' : '$amount $plural ago';
}

String formatTimestamp(int milliseconds) {
  final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dateOnly = DateTime(date.year, date.month, date.day);

  final time =
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  if (dateOnly == today) {
    return time;
  } else if (dateOnly == yesterday) {
    return 'Yesterday at $time'; //TODO: add l10n
  } else {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year} at $time';
  }
}
