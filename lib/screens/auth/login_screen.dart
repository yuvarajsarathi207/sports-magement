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

    final success = await AuthService.loginUser(
      email: emailCtrl.text,
      password: passCtrl.text,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      final user = AuthService.currentUser;
      if (user != null) {
        // Redirect based on role
        final route = user.role == UserRole.organization
            ? AppRoutes.orgDashboard
            : AppRoutes.playerDashboard;
        Navigator.pushReplacementNamed(context, route);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } else {
      setState(() {
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 60),
                      const AppLogo(height: 80),
                      const SizedBox(height: 40),
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
          AppLoader(isLoading: isLoading),
        ],
      ),
    );
  }
}
