import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../widgets/app_header.dart';

class PlayerTournamentList extends StatelessWidget {
  const PlayerTournamentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: AppStrings.tournamentList,
        showBack: true,
      ),
      body: Column(
        children: [
          // Category filter (based on sports category)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Chip(
                    label: const Text('All'),
                    onDeleted: null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Chip(
                    label: const Text('Cricket'),
                    onDeleted: null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Chip(
                    label: const Text('Football'),
                    onDeleted: null,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5, // Sample data
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('Tournament ${index + 1}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Location: [Hidden]'),
                        const Text('Start Date: 01/01/2024'),
                        const Text('Entry Fee: \$100'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.tournamentDetails,
                        arguments: {'tournamentId': index},
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

