import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_button.dart';

class TournamentDetails extends StatefulWidget {
  const TournamentDetails({super.key});

  @override
  State<TournamentDetails> createState() => _TournamentDetailsState();
}

class _TournamentDetailsState extends State<TournamentDetails> {
  bool isSubscribed = false;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final tournamentId = args?['tournamentId'] ?? 0;

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
      appBar: const AppHeader(
        title: AppStrings.tournamentDetails,
        showBack: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: SingleChildScrollView(
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
                      Text(
                        'Tournament $tournamentId',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        label: AppStrings.teamName,
                        value: 'Sample Team',
                      ),
                      _DetailRow(
                        label: AppStrings.location,
                        value: 'Full Location Details',
                      ),
                      _DetailRow(
                        label: AppStrings.startDate,
                        value: '01/01/2024',
                      ),
                      _DetailRow(
                        label: AppStrings.endDate,
                        value: '15/01/2024',
                      ),
                      _DetailRow(
                        label: AppStrings.slotCount,
                        value: '16 slots',
                      ),
                      _DetailRow(label: AppStrings.entryFee, value: '\$100'),
                      _DetailRow(label: AppStrings.ballType, value: 'Cricket'),
                      const SizedBox(height: 16),
                      const Text(
                        'Rules:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('Sample tournament rules and regulations...'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!isSubscribed)
                CustomButton(
                  text: AppStrings.subscribe,
                  icon: Icons.check_circle,
                  onPressed: () {
                    _showSubscribeDialog(context);
                  },
                  width: double.infinity,
                )
              else
                CustomButton(
                  text: AppStrings.subscribed,
                  icon: Icons.check_circle,
                  isOutlined: true,
                  onPressed: null,
                  width: double.infinity,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubscribeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.subscribe),
        content: const Text('Do you want to subscribe to this tournament?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.subscriptionPayment);
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
