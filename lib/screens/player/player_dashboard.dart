import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../widgets/app_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/simple_chart.dart';
import '../../widgets/tournament_table.dart';
import '../../constants/app_colors.dart';

class PlayerDashboard extends StatelessWidget {
  const PlayerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - replace with actual data from API
    final subscriptionStats = [
      ChartData(label: 'Jan', value: 2),
      ChartData(label: 'Feb', value: 3),
      ChartData(label: 'Mar', value: 5),
      ChartData(label: 'Apr', value: 4),
      ChartData(label: 'May', value: 6),
      ChartData(label: 'Jun', value: 8),
    ];

    final mySubscriptions = [
      TournamentTableData(
        name: 'Summer Cricket League',
        status: 'Upcoming',
        startDate: '2024-01-15',
        slots: 12,
        totalSlots: 16,
        entryFee: 100,
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.tournamentDetails,
          arguments: {'tournamentId': 0},
        ),
      ),
      TournamentTableData(
        name: 'Spring Basketball',
        status: 'Ongoing',
        startDate: '2024-01-10',
        slots: 14,
        totalSlots: 16,
        entryFee: 80,
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.tournamentDetails,
          arguments: {'tournamentId': 1},
        ),
      ),
      TournamentTableData(
        name: 'Winter Football Cup',
        status: 'Completed',
        startDate: '2023-12-20',
        slots: 20,
        totalSlots: 20,
        entryFee: 150,
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.tournamentDetails,
          arguments: {'tournamentId': 2},
        ),
      ),
    ];

    return Scaffold(
      appBar: AppHeader(
        title: AppStrings.playerDashboard,
        showBack: false,
        showProfile: true,
        onProfileTap: () => Navigator.pushNamed(context, AppRoutes.playerProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Subscriptions',
                    value: '12',
                    icon: Icons.subscriptions,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Upcoming',
                    value: '5',
                    icon: Icons.event,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Ongoing',
                    value: '3',
                    icon: Icons.play_circle,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Total Spent',
                    value: '\$1.2K',
                    icon: Icons.payments,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Chart
            SimpleBarChart(
              title: 'Tournament Subscriptions (Last 6 Months)',
              data: subscriptionStats,
            ),
            const SizedBox(height: 20),
            // My Subscriptions Table
            TournamentTable(
              data: mySubscriptions,
              onCreateTap: () => Navigator.pushNamed(
                context,
                AppRoutes.playerTournamentList,
              ),
            ),
            const SizedBox(height: 20),
            // Quick Actions
            Card(
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.playerTournamentList),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.list,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Browse Tournaments',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Discover and subscribe to tournaments',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
