import 'package:dio/dio.dart';
import 'package:nerimobile/models/gif.dart';

Future<List<GifCategory>> fetchGifCategories(Dio dio) async {
  final response = await dio.get('/tenor/categories');
  return (response.data as List<dynamic>)
      .map((category) => GifCategory.fromJson(category as Map<String, dynamic>))
      .toList();
}
