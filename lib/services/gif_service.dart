import 'package:dio/dio.dart';
import 'package:nerimobile/models/gif.dart';

Future<List<GifCategory>> fetchGifCategories(Dio dio) async {
  final response = await dio.get('/tenor/categories');
  return (response.data as List<dynamic>)
      .map((category) => GifCategory.fromJson(category as Map<String, dynamic>))
      .toList();
}

Future<GifPage> searchGifs(Dio dio, String query, {String? pos}) async {
  final response = await dio.get(
    '/v2/tenor/search',
    queryParameters: {'query': query, 'pos': ?pos},
  );
  final data = response.data as Map<String, dynamic>;
  final next = data['next'] as String?;

  return (
    gifs: (data['results'] as List<dynamic>)
        .map((gif) => Gif.fromJson(gif as Map<String, dynamic>))
        .toList(),
    //the last page reports an empty or zeroed cursor
    next: next == null || next.isEmpty || next == '0' ? null : next,
  );
}
