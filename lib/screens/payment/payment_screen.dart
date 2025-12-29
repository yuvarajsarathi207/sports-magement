import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_button.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: AppStrings.payment,
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Payment Summary',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const _PaymentRow(label: 'Tournament Publishing Fee', amount: '\$50'),
                    const Divider(),
                    const _PaymentRow(label: 'Total', amount: '\$50', isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Proceed to Payment',
              icon: Icons.payment,
              onPressed: () {
                // Simulate payment success
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment Successful! Tournament Published.')),
                );
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.orgDashboard,
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

class _PaymentRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isTotal;

  const _PaymentRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }
}

