import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../widgets/app_header.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_colors.dart';

class OrgDashboard extends StatelessWidget {
  const OrgDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppHeader(
        title: AppStrings.orgDashboard,
        showBack: false,
        showProfile: true,
        onProfileTap: () =>
            Navigator.pushNamed(context, AppRoutes.orgProfile),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// STATS
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Tournaments',
                    value: '24',
                    icon: Icons.emoji_events,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Ongoing',
                    value: '5',
                    icon: Icons.sports_cricket,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Draft',
                    value: '3',
                    icon: Icons.edit,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Revenue',
                    value: '₹2.4K',
                    icon: Icons.currency_rupee,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// ACTIONS
            _actionCard(
              context,
              title: "Create Tournament",
              subtitle: "Start a new tournament",
              icon: Icons.add_circle,
              route: AppRoutes.createTournament,
            ),

            const SizedBox(height: 16),

            _actionCard(
              context,
              title: "Manage Tournaments",
              subtitle: "View & manage tournaments",
              icon: Icons.emoji_events,
              route: AppRoutes.orgTournamentList,
            ),

            const SizedBox(height: 16),

            currentLiveTournaments()

          ],
        ),
      ),
    );
  }

  Widget currentLiveTournaments() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Tournaments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) {
                return Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Tournament ${index + 1}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required String route,
      }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(.1),
                child: Icon(icon,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}