import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hackoftrading/constants/app_routes.dart';
import 'package:hackoftrading/constants/app_strings.dart';
import 'package:hackoftrading/services/auth_service.dart';
import 'package:hackoftrading/utils/validators.dart';
import 'package:hackoftrading/widgets/app_loader.dart';
import 'package:hackoftrading/widgets/custom_button.dart';
import 'package:hackoftrading/widgets/custom_text_field.dart';
import 'package:hackoftrading/widgets/error_message.dart';
import 'package:hackoftrading/widgets/role_selector.dart';

import '../../utils/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _apiErrorIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final mobileCtl = TextEditingController();
  final pswCtl = TextEditingController();
  final emailCtrl = TextEditingController();
  final confirmPswCtl = TextEditingController();
  String? selectedRole;

  bool isLoading = false;
  String error = "";

  void register() async {
    try {
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

      final userdata = await AuthService.registerUser(
        username: emailCtrl.text.trim().split('@')[0],
        email: emailCtrl.text.trim(),
        password: pswCtl.text.trim(),
        mobile: mobileCtl.text.trim(),
        role: selectedRole!,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (userdata == null || userdata.trim().isEmpty) {
        setState(() => error = AppStrings.registerFailed);
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
          error = _nextApiError(messages, fallback: AppStrings.registerFailed);
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
        error = AppStrings.registerFailed;
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
    mobileCtl.dispose();
    pswCtl.dispose();
    confirmPswCtl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/logo.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              color: theme.colorScheme.background.withOpacity(0.75),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                              controller: pswCtl,
                              label: AppStrings.password,
                              obscureText: true,
                              validator: (value) =>
                                  Validators.password(value, minLength: 6),
                            ),

                            const SizedBox(height: 20),

                            CustomTextField(
                              controller: confirmPswCtl,
                              label: 'Confirm Password',
                              obscureText: true,
                              validator: (value) {
                                final val = value?.trim() ?? '';
                                if (val.isEmpty) {
                                  return 'Confirm password required';
                                }
                                if (val != pswCtl.text.trim()) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            CustomTextField(
                              controller: mobileCtl,
                              label: AppStrings.phone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (value) {
                                final baseError = Validators.phone(value);
                                if (baseError != null) return baseError;
                                final cleaned = (value ?? '').replaceAll(
                                  RegExp(r'[^\d]'),
                                  '',
                                );
                                if (cleaned.length != 10) {
                                  return 'Phone number must be 10 digits';
                                }
                                return null;
                              },
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
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.login,
                                );
                              },
                              child: const Text(AppStrings.haveAccount),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          AppLoader(isLoading: isLoading),
        ],
      ),
    );
  }
}
