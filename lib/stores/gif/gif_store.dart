import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/models/gif.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/gif_service.dart';

//avoids repeated rate limited requests
final gifCategoriesProvider = FutureProvider<List<GifCategory>>((ref) {
  ref.keepAlive();
  return fetchGifCategories(ref.read(dioProvider));
});
