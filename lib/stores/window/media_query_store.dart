import 'package:signals/signals.dart';

final screenWidth = signal(0.0);
final screenHeight = signal(0.0);

final isMobile = computed(() => screenWidth.value < 768);
