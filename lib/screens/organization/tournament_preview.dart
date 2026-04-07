import 'dart:convert';

import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../services/auth_service.dart';
import '../../utils/shared_preferences.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_button.dart';

class TournamentPreview extends StatefulWidget {
  /// Tournament data: from create form (no id) or from API (has id, team_name, etc.)
  final Map<String, dynamic>? tournamentData;

  const TournamentPreview({super.key, this.tournamentData});

  @override
  State<TournamentPreview> createState() => _TournamentPreviewState();
}

class _TournamentPreviewState extends State<TournamentPreview> {
  bool _isPublishing = false;
  bool _hideOrganizerActions = false;

  Map<String, dynamic> get _data => widget.tournamentData ?? {};

  bool get _hasId {
    final id = _data['id'];
    return id != null && id.toString().isNotEmpty;
  }

  int? get _tournamentId {
    final id = _data['id'];
    if (id == null) return null;
    if (id is int) return id;
    return int.tryParse(id.toString());
  }

  String _get(dynamic key, [String fallback = '—']) {
    final v = _data[key];
    if (v == null || v.toString().isEmpty) return fallback;
    return v.toString();
  }

  @override
  void initState() {
    super.initState();
    _resolveViewerRole();
  }

  Future<void> _resolveViewerRole() async {
    final viewerRole = _data['viewer_role']?.toString().toLowerCase();
    if (viewerRole == 'player') {
      if (mounted) setState(() => _hideOrganizerActions = true);
      return;
    }

    final raw = await AppPreferences.getCustom('userDetails');
    if (raw == null || raw.trim().isEmpty) return;
    try {
      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      final user = parsed['user'] as Map<String, dynamic>?;
      final role = user?['role']?.toString().toLowerCase();
      if (role == 'player' && mounted) {
        setState(() => _hideOrganizerActions = true);
      }
    } catch (_) {
      // Ignore malformed local user cache.
    }
  }

  Future<void> _publish() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.publish),
        content: Text(
          _hasId
              ? 'Publish this tournament? It will be visible to players.'
              : 'Save and publish this tournament? It will be created and then published.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Publish'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isPublishing = true);

    int? id = _tournamentId;

    if (id == null) {
      // From create screen: create draft first, then publish
      final created = await AuthService.createTournament(
        sportsCategoryId: _data['sports_category_id'] as int? ?? 1,
        teamName: _get('team_name', ''),
        location: _get('location', ''),
        locationDetails: _get('location_details', ''),
        startDate: _get(
          'start_date',
          DateTime.now().toIso8601String().split('T')[0],
        ),
        winningDate: _get(
          'winning_date',
          DateTime.now().toIso8601String().split('T')[0],
        ),
        slotCount: _data['slot_count'] is int
            ? _data['slot_count'] as int
            : int.tryParse(_get('slot_count', '0')) ?? 0,
        template: _get('template', ''),
        rules: _get('rules', ''),
        entryFee: _data['entry_fee'] is int
            ? _data['entry_fee'] as int
            : int.tryParse(_get('entry_fee', '0')) ?? 0,
        priceDetails: _get('price_details', 'Price breakdown'),
        ballType: _get('ball_type', 'cricket'),
      );
      id = created != null
          ? (created['id'] is int
                ? created['id'] as int
                : int.tryParse(created['id']?.toString() ?? ''))
          : null;
    }

    if (id != null) {
      final success = await AuthService.publishTournament(id);
      if (mounted) {
        setState(() => _isPublishing = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tournament published successfully')),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.orgDashboard,
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to publish tournament')),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create or publish tournament'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rawStatus = _get('status', '').toLowerCase();
    final isPublished = rawStatus == 'published';
    final statusLabel = rawStatus.isEmpty
        ? ''
        : '${rawStatus[0].toUpperCase()}${rawStatus.substring(1)}';

    return Scaffold(
      appBar: const AppHeader(
        title: AppStrings.previewTournament,
        showBack: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withOpacity(0.18),
                          colorScheme.surface.withOpacity(0.35),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: colorScheme.primary.withOpacity(
                                0.25,
                              ),
                              child: Icon(
                                Icons.emoji_events,
                                color: colorScheme.primary,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _get('team_name', 'Tournament'),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _get('ball_type', 'cricket').toUpperCase(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (statusLabel.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: rawStatus == 'published'
                                      ? Colors.green.withOpacity(0.15)
                                      : Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: rawStatus == 'published'
                                        ? Colors.green.shade300
                                        : Colors.orange.shade300,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Details sections
                _Section(
                  title: 'Details',
                  children: [
                    _DetailRow(
                      label: AppStrings.teamName,
                      value: _get('team_name'),
                    ),
                    _DetailRow(
                      label: AppStrings.location,
                      value: _get('location'),
                    ),
                    _DetailRow(
                      label: AppStrings.locationDetails,
                      value: _get('location_details'),
                    ),
                  ],
                ),
                _Section(
                  title: 'Schedule',
                  children: [
                    _DetailRow(
                      label: AppStrings.startDate,
                      value: _get('start_date'),
                    ),
                    _DetailRow(
                      label: AppStrings.endDate,
                      value: _get('winning_date'),
                    ),
                  ],
                ),
                _Section(
                  title: 'Match & entry',
                  children: [
                    _DetailRow(
                      label: AppStrings.slotCount,
                      value: _get('slot_count'),
                    ),
                    _DetailRow(
                      label: AppStrings.entryFee,
                      value: '₹${_get('entry_fee', '0')}',
                    ),
                    _DetailRow(
                      label: AppStrings.ballType,
                      value: _get('ball_type').toUpperCase(),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                _Section(
                  title: 'Interested Players',
                  children: [
                    Builder(
                      builder: (context) {
                        final interestsValue = _data['interests'];
                        final List<dynamic> interestsList =
                            interestsValue is List
                            ? interestsValue
                            : <dynamic>[];

                        final dynamic interestsCountValue =
                            _data['interests_count'];
                        int interestsCount = interestsList.length;
                        if (interestsCountValue is int) {
                          interestsCount = interestsCountValue;
                        } else if (interestsCountValue is num) {
                          interestsCount = interestsCountValue.toInt();
                        } else if (interestsCountValue != null) {
                          interestsCount =
                              int.tryParse(interestsCountValue.toString()) ??
                              interestsList.length;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  size: 18,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Interested: $interestsCount',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (interestsList.isEmpty)
                              Text(
                                'No interested players yet.',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              )
                            else
                              Column(
                                children: interestsList.map((interest) {
                                  final player = interest is Map
                                      ? interest['player']
                                      : null;
                                  final playerName = player is Map
                                      ? (player['name']?.toString() ?? 'Player')
                                      : 'Player';
                                  final playerMobile = player is Map
                                      ? player['mobile']
                                      : null;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.person,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                playerName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (playerMobile != null &&
                                                  playerMobile
                                                      .toString()
                                                      .trim()
                                                      .isNotEmpty)
                                                Text(
                                                  'Mobile: ${playerMobile.toString()}',
                                                  style: TextStyle(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                if (_get('template') != '—' || _get('rules') != '—')
                  _Section(
                    title: 'Rules & template',
                    children: [
                      if (_get('template') != '—')
                        _DetailRow(
                          label: AppStrings.template,
                          value: _get('template'),
                          maxLines: 4,
                        ),
                      if (_get('rules') != '—')
                        _DetailRow(
                          label: AppStrings.rules,
                          value: _get('rules'),
                          maxLines: 4,
                        ),
                    ],
                  ),

                const SizedBox(height: 24),

                if (!_hideOrganizerActions && !isPublished) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Edit',
                          isOutlined: true,
                          onPressed: () {
                            if (_hasId) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.createTournament,
                                arguments: _data,
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.publish,
                          onPressed: _isPublishing ? null : _publish,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
          if (_isPublishing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;

  const _DetailRow({
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
