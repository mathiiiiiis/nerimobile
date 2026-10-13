import 'package:dio/dio.dart';
import 'package:nerimobile/models/server.dart';
import 'package:nerimobile/models/server_invite.dart';

Future<void> leaveServer(Dio dio, String serverId) =>
    dio.post('/servers/$serverId/leave');

//owners get ever invite, everyone else only their own
Future<List<ServerInvite>> fetchServerInvites(Dio dio, String serverId) async {
  final response = await dio.get('/servers/$serverId/invites');
  return (response.data as List<dynamic>)
      .map((invite) => ServerInvite.fromJson(invite as Map<String, dynamic>))
      .toList();
}

Future<ServerInvite> createServerInvite(Dio dio, String serverId) async {
  final response = await dio.get('/servers/$serverId/invites');
  return ServerInvite.fromJson(response.data as Map<String, dynamic>);
}

Future<void> deleteServerInvite(Dio dio, String serverId, String code) =>
    dio.delete('/servers/$serverId/invites/$code');

//also resolves the id of a public server
Future<InvitePreview> fetchInvitePreview(Dio dio, String code) async {
  final response = await dio.get('/servers/invites/$code');
  return invitePreviewFromJson(response.data as Map<String, dynamic>);
}

Future<Server> joinServerByInvite(Dio dio, String code) async {
  final response = await dio.post('/servers/invites/$code');
  return Server.fromJson(response.data as Map<String, dynamic>);
}
