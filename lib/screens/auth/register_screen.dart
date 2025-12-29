import 'package:flutter/material.dart';
import 'package:hackoftrading/constants/app_routes.dart';
import 'package:hackoftrading/constants/app_strings.dart';
import 'package:hackoftrading/services/auth_service.dart';
import 'package:hackoftrading/utils/validators.dart';
import 'package:hackoftrading/widgets/app_loader.dart';
import 'package:hackoftrading/widgets/app_logo.dart';
import 'package:hackoftrading/widgets/custom_button.dart';
import 'package:hackoftrading/widgets/custom_text_field.dart';
import 'package:hackoftrading/widgets/error_message.dart';
import 'package:hackoftrading/widgets/role_selector.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final mobileCtl = TextEditingController();
  final pswCtl = TextEditingController();
  final emailCtrl = TextEditingController();
  String? selectedRole;

  bool isLoading = false;
  String error = "";

  void register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedRole == null) {
      setState(() {
        error = AppStrings.roleRequired;
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = "";
    });

    final success = await AuthService.registerUser(
      username: emailCtrl.text.split('@')[0],
      email: emailCtrl.text,
      password: pswCtl.text,
      mobile: mobileCtl.text,
      role: selectedRole!,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.registerSuccess)),
      );
      // Redirect based on role
      final route = selectedRole == 'organization' 
          ? AppRoutes.orgDashboard 
          : AppRoutes.playerDashboard;
      Navigator.pushReplacementNamed(context, route);
    } else {
      setState(() {
        error = AppStrings.registerFailed;
      });
    }
  }

  @override
  void dispose() {
    mobileCtl.dispose();
    pswCtl.dispose();
    emailCtrl.dispose();
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
                      const SizedBox(height: 40),
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
                        controller: pswCtl,
                        label: AppStrings.password,
                        obscureText: true,
                        validator: (value) => Validators.password(value, minLength: 6),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: mobileCtl,
                        label: AppStrings.phone,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: 20),
                      RoleSelector(
                        selectedRole: selectedRole,
                        onRoleSelected: (role) {
                          setState(() {
                            selectedRole = role;
                            error = "";
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        text: AppStrings.register,
                        onPressed: register,
                        isLoading: isLoading,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        },
                        child: const Text(AppStrings.haveAccount),
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
