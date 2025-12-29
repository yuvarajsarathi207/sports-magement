import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_button.dart';

class TournamentPreview extends StatelessWidget {
  const TournamentPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: AppStrings.previewTournament,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tournament Details',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(label: AppStrings.teamName, value: 'Sample Team'),
                    _DetailRow(label: AppStrings.location, value: 'Sample Location'),
                    _DetailRow(label: AppStrings.startDate, value: '01/01/2024'),
                    _DetailRow(label: AppStrings.winningDate, value: '15/01/2024'),
                    _DetailRow(label: AppStrings.slotCount, value: '16'),
                    _DetailRow(label: AppStrings.entryFee, value: '\$100'),
                    _DetailRow(label: AppStrings.ballType, value: 'Cricket'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Edit',
                    isOutlined: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: AppStrings.publish,
                    onPressed: () {
                      // Show payment dialog
                      _showPaymentDialog(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.payToBusiness),
        content: const Text('Do you want to proceed with payment to publish this tournament?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.payment);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

