import 'package:nerimobile/theme/core/token.dart';

class ThemeSpec {
  const ThemeSpec({
    required this.id,
    required this.name,
    this.maintainers = const [],
    this.values = const {},
    this.variables = const {},
  });

  final String id;
  final String name;
  final List<String> maintainers;
  final Map<NeriToken, String> values;
  final Map<String, String> variables;
}
