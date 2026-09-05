import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerimobile/services/api_client.dart';
import 'package:nerimobile/services/user_service.dart';
import 'package:nerimobile/stores/auth/auth_store.dart';
import 'package:nerimobile/theme/core/theme_data.dart';
import 'package:nerimobile/theme/core/token.dart';
import 'package:nerimobile/theme/sizing/spacing.dart';
import 'package:nerimobile/theme/typography/text_styles.dart';
import 'package:nerimobile/views/app_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _account = TextEditingController();
  final _password = TextEditingController();

  bool _busy = false;
  String? _error;
  String? _errorPath;

  @override
  void dispose() {
    _account.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;

    final account = _account.text.trim();
    final password = _password.text;

    final isEmail = account.contains('@');
    if (!isEmail && account.split(':').length != 2) {
      setState(() {
        _error =
            'Enter an email, or a username and tag like name:1234'; //TODO: add l10n
        _errorPath = 'email';
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _errorPath = null;
    });

    try {
      final token = await userLogin(
        ref.read(dioProvider),
        email: isEmail ? account : null,
        usernameAndTag: isEmail ? null : account,
        password: password,
      );
      await ref.read(authProvider.notifier).signIn(token);
    } on DioException catch (e) {
      final data = e.response?.data;
      setState(() {
        _error = data is Map && data['message'] is String
            ? data['message'] as String
            : 'Could not reach the server'; //TODO: add l10n
        _errorPath = data is Map ? data['path'] as String? : null;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.neri;
    final sizing = context.neriSize;

    return ColoredBox(
      color: colors[NeriToken.background],
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sizing.space(NeriSpacingRole.xl)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: sizing.space(NeriSpacingRole.lg),
              children: [
                Text(
                  'Log In', //TODO: add l10n
                  style: context.neriText[NeriTextRole.titleLarge].copyWith(
                    color: colors[NeriToken.text],
                  ),
                ),
                AppTextField(
                  label: 'Email / username:tag', //TODO: add l10n
                  controller: _account,
                  errorText: _errorPath == 'email' ? _error : null,
                  onSubmitted: (_) => _submit(),
                ),
                AppTextField(
                  label: 'Password', //TODO: add l10n
                  controller: _password,
                  obscureText: true,
                  errorText: _errorPath == 'password' ? _error : null,
                  onSubmitted: (_) => _submit(),
                ),
                if (_error != null && _errorPath == null)
                  Text(
                    _error!,
                    style: context.neriText[NeriTextRole.bodySmall].copyWith(
                      color: colors[NeriToken.alert],
                    ),
                  ),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Text(
                    _busy ? 'Logging in...' : 'Log in',
                  ), //TODO: add l10n
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
