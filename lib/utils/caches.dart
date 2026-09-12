import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final avatarCache = CacheManager(
  Config(
    'neri_avatars',
    stalePeriod: const Duration(days: 30),
    maxNrOfCacheObjects: 1000,
  ),
);

final emojiCache = CacheManager(
  Config(
    'neri_emojis',
    stalePeriod: const Duration(days: 60),
    maxNrOfCacheObjects: 2000,
  ),
);

final mediaCache = CacheManager(
  Config(
    'neri_media',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 300,
  ),
);
