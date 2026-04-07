import 'package:flutter/material.dart';
import 'package:hackoftrading/services/auth_service.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../widgets/app_header.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_colors.dart';

class PlayerDashboard extends StatefulWidget {
  const PlayerDashboard({super.key});

  @override
  State<PlayerDashboard> createState() => _PlayerDashboardState();
}

class _PlayerDashboardState extends State<PlayerDashboard> {
  static const String _upiId = 'sportsmagement@upi';
  List<dynamic>? tournamentList = [];
  final Set<int> _interestLoadingIds = <int>{};
  final Set<int> _interestedTournamentIds = <int>{};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
        title: AppStrings.playerDashboard,
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
                      value: tournamentList!.length.toString(),
                      icon: Icons.emoji_events,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Ongoing',
                      value: '0',
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
                      value: '0',
                      icon: Icons.edit,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Revenue',
                      value: '₹0K',
                      icon: Icons.currency_rupee,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// ACTIONS
              // _actionCard(
              //   context,
              //   title: "Create Tournament",
              //   subtitle: "Start a new tournament",
              //   icon: Icons.add_circle,
              //   route: AppRoutes.createTournament,
              // ),
              const SizedBox(height: 16),

              FutureBuilder(
                future: AuthService.getPlayerTournaments(),
                builder: (context, snapshot) {
                  /// Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  /// Error
                  if (snapshot.hasError) {
                    return const Center(child: Text("Something went wrong"));
                  }

                  /// No Data
                  tournamentList = snapshot.data ?? [];

                  return tournamentList!.isNotEmpty
                      ? currentLiveTournaments()
                      : Expanded(
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
                        );
                },
              ),
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
              itemCount: tournamentList?.length ?? 0,
              itemBuilder: (context, index) {
                final tournament = tournamentList![index];
                final tournamentId = tournament['id'];
                final hasValidId = tournamentId is int;
                final isInterestLoading =
                    hasValidId && _interestLoadingIds.contains(tournamentId);
                final isInterested =
                    hasValidId &&
                    _interestedTournamentIds.contains(tournamentId);

                return Container(
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
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Entry Fee: ₹${tournament['entry_fee'] ?? '0'}",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Row(
                            children: [
                              Text(
                                "Slots: ${tournament['slot_count'] ?? 0}",
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              hasValidId
                                  ? InkWell(
                                      onTap: isInterestLoading
                                          ? null
                                          : () => _markInterest(tournamentId),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: isInterestLoading
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Icon(
                                                isInterested
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isInterested
                                                    ? Colors.red
                                                    : colorScheme
                                                          .onSurfaceVariant,
                                                size: 22,
                                              ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: colorScheme.primary.withOpacity(
                                isDark ? 0.7 : 1,
                              ),
                            ),
                          ),
                          onPressed: () => _requestDetails(tournament),
                          child: const Text('Request Details'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markInterest(int tournamentId) async {
    if (_interestLoadingIds.contains(tournamentId)) return;

    setState(() {
      _interestLoadingIds.add(tournamentId);
    });

    final isSuccess = await AuthService.markTournamentInterest(tournamentId);

    if (!mounted) return;

    setState(() {
      _interestLoadingIds.remove(tournamentId);
      if (isSuccess) {
        _interestedTournamentIds.add(tournamentId);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSuccess
              ? 'Marked as interested'
              : 'Could not mark interest. Please try again.',
        ),
      ),
    );
  }

  Future<void> _requestDetails(Map<String, dynamic> tournament) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Tournament Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Scan QR and complete payment to view full details.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Image.network(
              'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=${Uri.encodeComponent('upi://pay?pa=$_upiId&pn=SportsMagement')}',
              width: 180,
              height: 180,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.qr_code_2, size: 120),
            ),
            const SizedBox(height: 8),
            const SelectableText('UPI ID: $_upiId'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Done'),
          ),
        ],
      ),
    );

    if (proceed == true && mounted) {
      final previewArgs = Map<String, dynamic>.from(tournament)
        ..['viewer_role'] = 'player';
      Navigator.pushNamed(
        context,
        AppRoutes.tournamentPreview,
        arguments: previewArgs,
      );
    }
  }
}
