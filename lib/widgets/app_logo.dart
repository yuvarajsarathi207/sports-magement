import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double height;
  final double? width;

  const AppLogo({
    super.key,
    this.height = 70,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.jpg',
      height: height,
      width: width,
      fit: BoxFit.contain,
    );
  }
}

