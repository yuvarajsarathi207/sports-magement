import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hackoftrading/constants/app_routes.dart';
import 'package:hackoftrading/constants/app_strings.dart';
import 'package:hackoftrading/models/user_model.dart';
import 'package:hackoftrading/services/auth_service.dart';
import 'package:hackoftrading/utils/validators.dart';
import 'package:hackoftrading/widgets/app_loader.dart';
import 'package:hackoftrading/widgets/app_logo.dart';
import 'package:hackoftrading/widgets/custom_button.dart';
import 'package:hackoftrading/widgets/custom_text_field.dart';
import 'package:hackoftrading/widgets/error_message.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    emailCtrl.text = 'john1@example.com';
    passCtrl.text = 'password123';
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

    setState(() {
      error = "";
      isLoading = true;
    });

    try {
      final userdata = await AuthService.loginUser(
        email: emailCtrl.text,
        password: passCtrl.text,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (userdata == null || userdata.trim().isEmpty) {
        setState(() {
          error = AppStrings.loginFailed;
        });
        return;
      }

      final data = jsonDecode(userdata) as Map<String, dynamic>?;
      final user = data?['user'] as Map<String, dynamic>?;
      final role = user?['role'] as String?;

      String? route;
      if (role == 'organizer' || role == 'organization') {
        route = AppRoutes.orgDashboard;
      } else if (role == 'player') {
        route = AppRoutes.playerDashboard;
      }

        Navigator.pushNamedAndRemoveUntil(
          context,
          route!,
          (route) => false,
        );
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

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        validator: (value) => Validators.password(value, minLength: 6),
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
