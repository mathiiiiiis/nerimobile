import 'package:dio/dio.dart';
import 'package:nerimobile/models/user_details.dart';

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

Future<UserDetails> fetchUserDetails(Dio dio, String userId) async {
  final response = await dio.get('/users/$userId');
  return UserDetails.fromJson(response.data as Map<String, dynamic>);
}
