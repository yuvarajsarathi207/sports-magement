import 'dart:convert';

import 'package:flutter/material.dart';

import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../services/auth_service.dart';
import '../../utils/shared_preferences.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_button.dart';

class OrgProfile extends StatefulWidget {
  const OrgProfile({super.key});

  @override
  State<OrgProfile> createState() => _OrgProfileState();
}

class _OrgProfileState extends State<OrgProfile> {
  String role = '';
  String email = '';
  String mobile = '';
  String name = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final user = await AppPreferences.getCustom('userDetails');

    if (user != null) {
      final data = jsonDecode(user);
      final userData = data['user'];

      setState(() {
        role = userData['role'] ?? '';
        email = userData['email'] ?? '';
        mobile = userData['mobile'] ?? '';
        name = userData['name'] ?? '';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bgTop = Color.alphaBlend(
      Colors.grey.withOpacity(0.18),
      colorScheme.surface,
    );
    final bgBottom = Color.alphaBlend(
      Colors.grey.withOpacity(0.10),
      colorScheme.surfaceContainerLowest,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const AppHeader(title: AppStrings.profile, showBack: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _ProfileRow(label: 'Email', value: email),
              _ProfileRow(label: 'Mobile', value: mobile),
              _ProfileRow(label: 'Username', value: name),
              _ProfileRow(label: 'Role', value: role),
              const SizedBox(height: 30),
              CustomButton(
                text: AppStrings.logout,
                icon: Icons.logout,
                width: double.infinity,
                onPressed: () {
                  AuthService.logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
