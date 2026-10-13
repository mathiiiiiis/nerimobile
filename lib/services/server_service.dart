import 'package:dio/dio.dart';

Future<void> leaveServer(Dio dio, String serverId) =>
    dio.post('/servers/$serverId/leave');
