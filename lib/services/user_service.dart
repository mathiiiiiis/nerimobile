import 'package:dio/dio.dart';

Future<String> userLogin(
  Dio dio, {
  String? email,
  String? usernameAndTag,
  required String password,
}) async {
  final response = await dio.post(
    '/users/login',
    data: {
      'email': ?email,
      'usernameAndTag': ?usernameAndTag,
      'password': password,
    },
  );
  return response.data['token'] as String;
}
