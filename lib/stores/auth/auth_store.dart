import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/utils/secure_storage.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, String?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() => getToken();

  Future<void> signIn(String token) async {
    await saveToken(token);
    state = AsyncData(token);
  }

  Future<void> signOut() async {
    await deleteToken();
    state = const AsyncData(null);
  }
}
