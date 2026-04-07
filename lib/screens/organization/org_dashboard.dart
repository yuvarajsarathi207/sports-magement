import 'package:flutter/material.dart';
import 'package:hackoftrading/services/auth_service.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../widgets/app_header.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_colors.dart';

class OrgDashboard extends StatefulWidget {
  const OrgDashboard({super.key});

  @override
  State<OrgDashboard> createState() => _OrgDashboardState();
}

class _OrgDashboardState extends State<OrgDashboard> {
  List<dynamic> tournamentList = const [];
  Map<String, dynamic> _stats = const {};
  bool _loading = true;
  String? _error;

  int _safeInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is double) return v.toInt();
    return 0;
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AuthService.getOrganizerDashboard();
      if (!mounted) return;
      setState(() {
        tournamentList =
            (data?['tournaments'] is List) ? List<dynamic>.from(data!['tournaments']) : <dynamic>[];
        _stats = (data?['stats'] is Map)
            ? Map<String, dynamic>.from(data!['stats'])
            : <String, dynamic>{};
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Something went wrong';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

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
      appBar: AppHeader(
        title: AppStrings.orgDashboard,
        showBack: false,
        showProfile: true,
        onProfileTap: () => Navigator.pushNamed(context, AppRoutes.orgProfile),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// STATS
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Tournaments',
                      value: _safeInt(_stats['total_tournaments']).toString(),
                      icon: Icons.emoji_events,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Ongoing',
                      value: _safeInt(_stats['active_tournaments']).toString(),
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
                      value: tournamentList
                          .where((t) => (t is Map) && (t['status'] == 'draft'))
                          .length
                          .toString(),
                      icon: Icons.edit,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Open',
                      value: _safeInt(_stats['open_tournaments']).toString(),
                      icon: Icons.lock_open,
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
              if (_loading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Text(
                      _error!,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              else if (tournamentList.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No tournaments available.\nCreate your first tournament!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                currentLiveTournaments(),
            ],
          ),
        ),
      ),
    );
  }

  Widget currentLiveTournaments() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              itemCount: tournamentList.length,
              itemBuilder: (context, index) {
                final tournament = tournamentList[index];
                final interestsCount =
                    tournament['interests_count'] ??
                    (tournament['interests'] is List
                        ? tournament['interests'].length
                        : 0);
                final interestsCountStr = interestsCount.toString();

                return InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.tournamentPreview,
                    arguments: tournament,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? colorScheme.outline.withOpacity(0.35)
                            : Colors.transparent,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          color: isDark
                              ? Colors.black.withOpacity(0.35)
                              : Colors.black.withOpacity(0.08),
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Tournament Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                tournament['team_name'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: tournament['status'] == "published"
                                    ? (isDark
                                          ? Colors.green.withOpacity(0.18)
                                          : Colors.green.shade100)
                                    : (isDark
                                          ? Colors.orange.withOpacity(0.18)
                                          : Colors.orange.shade100),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tournament['status'] ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: tournament['status'] == "published"
                                      ? Colors.green.shade300
                                      : Colors.orange.shade300,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// Sport Category
                        Row(
                          children: [
                            const Icon(
                              Icons.sports_soccer,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tournament['sports_category']?['name'] ?? '',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        /// Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tournament['location'] ?? '',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// Bottom Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Entry Fee: ₹${tournament['entry_fee'] ?? '0'}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Slots: ${tournament['slot_count'] ?? 0}",
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      size: 16,
                                      color: Colors.red.shade400,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Interested: $interestsCountStr",
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(.1),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
