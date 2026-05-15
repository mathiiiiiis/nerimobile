import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nerimobile/services/user_service.dart';
import 'package:nerimobile/utils/secure_storage.dart';
import 'package:nerimobile/views/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await getToken();
    if (!mounted) return;
    if (token != null) {
      context.go('/app');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final token = await userLogin(email, password);
      await saveToken(token);
      if (!mounted) return;
      context.go('/app');
    } on DioException catch (e) {
      print(e.response?.statusCode);
      print(e.response?.data);
    }
  }

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerHigh,
    child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Login to continue",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 300,
            child: AppTextField(
              label: 'Email',
              controller: _emailController,
              focusNode: _emailFocus,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
          ),
          SizedBox(
            width: 300,
            child: AppTextField(
              label: 'Password',
              obscureText: true,
              controller: _passwordController,
              focusNode: _passwordFocus,
              onSubmitted: (_) => _handleLogin(),
            ),
          ),
          SizedBox(
            width: 300,
            child: Ink(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: _handleLogin,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
