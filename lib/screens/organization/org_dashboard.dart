import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../widgets/app_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/simple_chart.dart';
import '../../widgets/tournament_table.dart';
import '../../constants/app_colors.dart';

class OrgDashboard extends StatelessWidget {
  const OrgDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - replace with actual data from API
    final tournamentStats = [
      ChartData(label: 'Jan', value: 5),
      ChartData(label: 'Feb', value: 8),
      ChartData(label: 'Mar', value: 12),
      ChartData(label: 'Apr', value: 10),
      ChartData(label: 'May', value: 15),
      ChartData(label: 'Jun', value: 18),
    ];

    final recentTournaments = [
      TournamentTableData(
        name: 'Summer Cricket League',
        status: 'Published',
        startDate: '2024-01-15',
        slots: 12,
        totalSlots: 16,
        entryFee: 100,
        onTap: () => Navigator.pushNamed(context, AppRoutes.orgTournamentList),
      ),
      TournamentTableData(
        name: 'Winter Football Cup',
        status: 'Draft',
        startDate: '2024-02-01',
        slots: 0,
        totalSlots: 20,
        entryFee: 150,
        onTap: () => Navigator.pushNamed(context, AppRoutes.orgTournamentList),
      ),
      TournamentTableData(
        name: 'Spring Basketball',
        status: 'Ongoing',
        startDate: '2024-01-10',
        slots: 14,
        totalSlots: 16,
        entryFee: 80,
        onTap: () => Navigator.pushNamed(context, AppRoutes.orgTournamentList),
      ),
    ];

    return Scaffold(
      appBar: AppHeader(
        title: AppStrings.orgDashboard,
        showBack: false,
        showProfile: true,
        onProfileTap: () => Navigator.pushNamed(context, AppRoutes.orgProfile),
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
                    title: 'Total Tournaments',
                    value: '24',
                    icon: Icons.tour,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Published',
                    value: '18',
                    icon: Icons.publish,
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
                    value: '4',
                    icon: Icons.edit,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Total Revenue',
                    value: '\$2.4K',
                    icon: Icons.attach_money,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Chart
            SimpleBarChart(
              title: 'Tournaments Created (Last 6 Months)',
              data: tournamentStats,
            ),
            const SizedBox(height: 20),
            // Tournament Table
            TournamentTable(
              data: recentTournaments,
              onCreateTap: () => Navigator.pushNamed(
                context,
                AppRoutes.createTournament,
              ),
            ),
            const SizedBox(height: 20),
            // Quick Actions
            Card(
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.orgTournamentList),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tour,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tournament Management',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Create and manage your tournaments',
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
