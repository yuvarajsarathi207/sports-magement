import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hackoftrading/constants/app_routes.dart';
import 'package:hackoftrading/constants/app_strings.dart';
import 'package:hackoftrading/services/auth_service.dart';
import 'package:hackoftrading/utils/shared_preferences.dart';
import 'package:hackoftrading/utils/validators.dart';
import 'package:hackoftrading/widgets/custom_button.dart';
import 'package:hackoftrading/widgets/custom_text_field.dart';
import 'package:hackoftrading/widgets/error_message.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _apiErrorIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (kDebugMode) {
      emailCtrl.text = 'john1@example.com';
      passCtrl.text = 'password123';
    }
  }

  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool isLoading = false;
  String error = "";

  void login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    setState(() {
      error = "";
      isLoading = true;
    });

    try {
      final userdata = await AuthService.loginUser(
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (userdata == null || userdata.trim().isEmpty) {
        setState(() => error = AppStrings.loginFailed);
        return;
      }

      final data = jsonDecode(userdata) as Map<String, dynamic>?;
      final token = data?['token']?.toString();
      final user = data?['user'] as Map<String, dynamic>?;
      final role = user?['role'] as String?;

      // If token/user missing, treat as API error response.
      if (token == null || token.trim().isEmpty || user == null) {
        final messages = _extractApiErrorMessages(data);
        setState(() {
          error = _nextApiError(messages, fallback: AppStrings.loginFailed);
          isLoading = false;
        });
        return;
      }

      // Persist session so splash sends to dashboard on next app open
      await AppPreferences.setString('token', token);
      await AppPreferences.setCustom('userDetails', userdata);

      String? route;
      if (role == 'organizer' || role == 'organization') {
        route = AppRoutes.orgDashboard;
      } else if (role == 'player') {
        route = AppRoutes.playerDashboard;
      }

      if (route != null) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
      } else {
        setState(() => error = AppStrings.loginFailed);
      }
    } catch (e, stack) {
      debugPrint('Login error: $e');
      debugPrint(stack.toString());
      if (!mounted) return;
      setState(() {
        isLoading = false;
        error = AppStrings.loginFailed;
      });
    }
  }

  List<String> _extractApiErrorMessages(Map<String, dynamic>? data) {
    if (data == null) return const <String>[];
    final List<String> messages = <String>[];

    final msg = data['message'];
    if (msg != null && msg.toString().trim().isNotEmpty) {
      messages.add(msg.toString().trim());
    }

    final errors = data['errors'];
    if (errors is Map) {
      for (final entry in errors.entries) {
        final v = entry.value;
        if (v is List) {
          for (final item in v) {
            final s = item?.toString().trim();
            if (s != null && s.isNotEmpty) messages.add(s);
          }
        } else {
          final s = v?.toString().trim();
          if (s != null && s.isNotEmpty) messages.add(s);
        }
      }
    }

    final unique = <String>[];
    for (final m in messages) {
      if (!unique.contains(m)) unique.add(m);
    }
    return unique;
  }

  String _nextApiError(List<String> messages, {required String fallback}) {
    if (messages.isEmpty) return fallback;
    final msg = messages[_apiErrorIndex % messages.length];
    _apiErrorIndex++;
    return msg;
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/logo.jpg',
              fit: BoxFit.cover,
              cacheWidth: 1080,
              cacheHeight: 1920,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: theme.colorScheme.background.withOpacity(0.75),
            ),
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ErrorMessage(
                        message: error,
                        onDismiss: () => setState(() => error = ""),
                      ),
                      CustomTextField(
                        controller: emailCtrl,
                        label: AppStrings.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: passCtrl,
                        label: AppStrings.password,
                        obscureText: true,
                        validator: (value) =>
                            Validators.password(value, minLength: 6),
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        text: AppStrings.login,
                        onPressed: login,
                        isLoading: isLoading,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: const Text(AppStrings.dontHaveAccount),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // AppLoader(isLoading: isLoading),
        ],
      ),
    );
  }
}
