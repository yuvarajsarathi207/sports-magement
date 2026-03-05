import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hackoftrading/utils/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_routes.dart';

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
    await Future.delayed(const Duration(seconds: 4));

    final userdata = await AppPreferences.getCustom('userDetails');

    if (!mounted) return;

    if (userdata != null && userdata.isNotEmpty) {
      final data = jsonDecode(userdata);
      String role = data['user']['role'];

      Navigator.pushNamedAndRemoveUntil(
        context,
        role == 'organizer'
            ? AppRoutes.orgDashboard
            : AppRoutes.playerDashboard,
            (route) => false,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
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
            ),
          ),
          Center(
            child: Lottie.asset(
              'assets/images/olympicsloader.json',
              width: 150,
              height: 150,
              repeat: true,
            ),
          ),
        ],
      ),
    );
  }
}
