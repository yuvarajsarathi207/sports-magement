import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_button.dart';

class OrgTournamentList extends StatelessWidget {
  const OrgTournamentList({super.key});

  @override
  Widget build(BuildContext context) {
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
      appBar: const AppHeader(title: AppStrings.tournamentList, showBack: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                text: AppStrings.createTournament,
                icon: Icons.add,
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.createTournament),
                width: double.infinity,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 0, // Replace with actual tournament count
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: const Text('Tournament Name'),
                      subtitle: const Text('Status: Draft'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to edit tournament
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
