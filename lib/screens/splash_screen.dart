import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    // Wait for splash screen animation
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if user is authenticated
    final isAuthenticated = AuthService.isAuthenticated;
    final user = AuthService.currentUser;
    
    if (!mounted) return;
    
    if (isAuthenticated && user != null) {
      // Redirect based on role
      final route = user.role == UserRole.organization
          ? AppRoutes.orgDashboard
          : AppRoutes.playerDashboard;
      Navigator.pushReplacementNamed(context, route);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

