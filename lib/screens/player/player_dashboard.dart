import 'package:flutter/material.dart';
import 'package:hackoftrading/services/auth_service.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';
import '../../models/tournament_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/stat_card.dart';

class PlayerDashboard extends StatefulWidget {
  const PlayerDashboard({super.key});

  @override
  State<PlayerDashboard> createState() => _PlayerDashboardState();
}

class _PlayerDashboardState extends State<PlayerDashboard> {
  static const String _upiId = 'sportsmagement@upi';
  List<Map<String, dynamic>> tournamentList = const [];
  BallType _selectedBallType = BallType.cricket;
  final Set<int> _interestLoadingIds = <int>{};
  final Set<int> _interestedTournamentIds = <int>{};

  bool _listLoading = true;
  String? _listError;

  int _subscriptionsTotal = 0;
  int _subscriptionsPending = 0;
  int _interestsTotal = 0;

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  List<Map<String, dynamic>> _extractTournamentsFromPlayerDashboard(
    Map<String, dynamic>? dashboard,
  ) {
    final Map<int, Map<String, dynamic>> byId = {};

    final subs = (dashboard?['subscriptions'] is List)
        ? List<dynamic>.from(dashboard!['subscriptions'])
        : const <dynamic>[];
    final ints = (dashboard?['interests'] is List)
        ? List<dynamic>.from(dashboard!['interests'])
        : const <dynamic>[];

    for (final s in subs) {
      if (s is! Map) continue;
      final t = s['tournament'];
      if (t is! Map) continue;
      final id = _asInt(t['id']);
      if (id == 0) continue;
      byId[id] = Map<String, dynamic>.from(t);
    }
    for (final i in ints) {
      if (i is! Map) continue;
      final t = i['tournament'];
      if (t is! Map) continue;
      final id = _asInt(t['id']);
      if (id == 0) continue;
      byId[id] = Map<String, dynamic>.from(t);
    }

    final list = byId.values.toList();
    list.sort((a, b) => _asInt(b['id']).compareTo(_asInt(a['id'])));
    return list;
  }

  BallType? _parseBallTypeField(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    var ball = raw.toLowerCase().trim();
    if (ball.contains('.')) ball = ball.split('.').last;
    ball = ball.replaceAll(RegExp(r'[\s-]+'), '_');
    if (ball == 'soccer') ball = 'football';
    for (final e in BallType.values) {
      if (e.name == ball) return e;
    }
    return null;
  }

  BallType? _inferBallTypeFromCategoryName(String catName) {
    if (catName.contains('football') || catName.contains('soccer')) {
      return BallType.football;
    }
    if (catName.contains('cricket')) return BallType.cricket;
    if (catName.contains('basketball')) return BallType.basketball;
    if (catName.contains('tennis')) return BallType.tennis;
    if (catName.contains('volleyball')) return BallType.volleyball;
    return null;
  }

  /// Single source of truth for filter + list row: merges `ball_type` with `sports_category`.
  /// When the API sends a default `ball_type` (e.g. cricket) but the category name matches
  /// another sport (e.g. Football), we trust the category so the list matches the dropdown.
  BallType _ballTypeFromMap(dynamic tournament) {
    if (tournament is! Map) return BallType.other;
    final map = tournament;

    final raw = map['ball_type']?.toString().trim() ??
        map['ballType']?.toString().trim();
    final fromField = _parseBallTypeField(raw);

    final cat = map['sports_category'];
    final catName = cat is Map
        ? (cat['name']?.toString().toLowerCase() ?? '')
        : '';
    final fromCat = _inferBallTypeFromCategoryName(catName);

    if (fromField != null && fromCat != null) {
      if (fromField == fromCat) return fromField;
      // Backend often stores a default ball_type while category reflects the real sport.
      if (fromField == BallType.cricket && fromCat == BallType.football) {
        return BallType.football;
      }
      if (fromField == BallType.football && fromCat == BallType.cricket) {
        return BallType.cricket;
      }
      return fromField;
    }
    if (fromField != null) return fromField;
    if (fromCat != null) return fromCat;
    return BallType.other;
  }

  List<dynamic> get _filteredTournaments {
    final list = tournamentList;
    return list.where((t) => _ballTypeFromMap(t) == _selectedBallType).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchPlayerTournaments();
  }

  Future<void> _fetchPlayerTournaments() async {
    setState(() {
      _listLoading = true;
      _listError = null;
    });
    try {
      final dash = await AuthService.getPlayerDashboard();
      if (!mounted) return;
      setState(() {
        final subs = (dash?['subscriptions'] is List)
            ? List<dynamic>.from(dash!['subscriptions'])
            : const <dynamic>[];
        final ints = (dash?['interests'] is List)
            ? List<dynamic>.from(dash!['interests'])
            : const <dynamic>[];

        _subscriptionsTotal = subs.length;
        _subscriptionsPending = subs
            .where(
              (e) => e is Map && (e['status']?.toString().toLowerCase() == 'pending'),
            )
            .length;
        _interestsTotal = ints.length;

        tournamentList = _extractTournamentsFromPlayerDashboard(dash);
        _listLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _listLoading = false;
        _listError = 'Something went wrong';
      });
    }
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Tournaments',
                      value: _filteredTournaments.length.toString(),
                      icon: Icons.emoji_events,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Subscriptions',
                      value: _subscriptionsTotal.toString(),
                      icon: Icons.how_to_reg,
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
                      title: 'Pending',
                      value: _subscriptionsPending.toString(),
                      icon: Icons.pending_actions,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Interests',
                      value: _interestsTotal.toString(),
                      icon: Icons.favorite,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Live Tournaments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _ballTypeDropdown(colorScheme),
              const SizedBox(height: 12),
              if (_listLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_listError != null)
                Expanded(
                  child: Center(
                    child: Text(
                      _listError!,
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
                _tournamentListBody(),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForBallType(BallType type) {
    switch (type) {
      case BallType.cricket:
        return Icons.sports_cricket;
      case BallType.football:
        return Icons.sports_soccer;
      case BallType.basketball:
        return Icons.sports_basketball;
      case BallType.tennis:
        return Icons.sports_tennis;
      case BallType.volleyball:
        return Icons.sports_volleyball;
      case BallType.other:
        return Icons.sports;
    }
  }

  Widget _ballTypeDropdown(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<BallType>(
      value: _selectedBallType,
      decoration: InputDecoration(
        labelText: AppStrings.ballType,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(
          isDark ? 0.35 : 0.5,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.35),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.35),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: BallType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.name.toUpperCase()),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectedBallType = v!),
    );
  }

  Widget _tournamentListBody() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredTournaments;
    return Expanded(
      child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No ${_selectedBallType.name} tournaments right now.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final tournament = filtered[index];
                final tournamentId = tournament['id'];
                final hasValidId = tournamentId is int;
                final isInterestLoading =
                    hasValidId && _interestLoadingIds.contains(tournamentId);
                final isInterested =
                    hasValidId &&
                    _interestedTournamentIds.contains(tournamentId);
                final resolvedBall = _ballTypeFromMap(tournament);

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
                          Icon(
                            _iconForBallType(resolvedBall),
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            resolvedBall.name.toUpperCase(),
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
