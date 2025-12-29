import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_button.dart';

class OrgProfile extends StatelessWidget {
  const OrgProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: const AppHeader(
        title: AppStrings.profile,
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile Information',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _ProfileRow(label: 'Email', value: user?.email ?? 'N/A'),
                    _ProfileRow(label: 'Mobile', value: user?.mobile ?? 'N/A'),
                    _ProfileRow(label: 'Username', value: user?.username ?? 'N/A'),
                    _ProfileRow(
                      label: 'Role',
                      value: user?.role == null
                          ? 'N/A'
                          : user!.role.toString().split('.').last.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: AppStrings.logout,
              icon: Icons.logout,
              onPressed: () {
                AuthService.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              width: double.infinity,
            ),
          ],
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
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

