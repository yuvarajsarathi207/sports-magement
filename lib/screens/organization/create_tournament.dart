import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../models/tournament_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/error_message.dart';
import '../../utils/validators.dart';

class CreateTournament extends StatefulWidget {
  final TournamentModel? tournament;

  /// When opening from dashboard preview (edit draft), API response map (snake_case).
  final Map<String, dynamic>? editData;

  const CreateTournament({super.key, this.tournament, this.editData});

  @override
  State<CreateTournament> createState() => _CreateTournamentState();
}

class _CreateTournamentState extends State<CreateTournament> {
  final _formKey = GlobalKey<FormState>();
  static const String _upiId = 'sportsmagement@upi';

  final teamNameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final slotCountCtrl = TextEditingController();
  final templateCtrl = TextEditingController();
  final rulesCtrl = TextEditingController();
  final entryFeeCtrl = TextEditingController();
  final locationDetailsCtrl = TextEditingController();

  DateTime? startDate;
  DateTime? winningDate;

  BallType selectedBallType = BallType.cricket;

  bool isLoading = false;
  String error = "";

  @override
  void initState() {
    super.initState();

    if (widget.editData != null) {
      _fillFromEditData(widget.editData!);
    } else if (widget.tournament != null) {
      final t = widget.tournament!;
      teamNameCtrl.text = t.teamName;
      locationCtrl.text = t.location;
      slotCountCtrl.text = t.slotCount.toString();
      templateCtrl.text = t.template;
      rulesCtrl.text = t.rules;
      entryFeeCtrl.text = t.entryFee.toString();
      locationDetailsCtrl.text = t.locationDetails;
      startDate = t.startDate;
      winningDate = t.winningDate;
      selectedBallType = t.ballType;
    }
  }

  void _fillFromEditData(Map<String, dynamic> d) {
    teamNameCtrl.text = d['team_name']?.toString() ?? '';
    locationCtrl.text = d['location']?.toString() ?? '';
    locationDetailsCtrl.text = d['location_details']?.toString() ?? '';
    slotCountCtrl.text = d['slot_count']?.toString() ?? '';
    templateCtrl.text = d['template']?.toString() ?? '';
    rulesCtrl.text = d['rules']?.toString() ?? '';
    entryFeeCtrl.text = d['entry_fee']?.toString() ?? '';
    if (d['start_date'] != null) {
      try {
        startDate = DateTime.parse(d['start_date'].toString());
      } catch (_) {}
    }
    if (d['winning_date'] != null) {
      try {
        winningDate = DateTime.parse(d['winning_date'].toString());
      } catch (_) {}
    }
    final ball = d['ball_type']?.toString().toLowerCase();
    if (ball != null) {
      selectedBallType = BallType.values.firstWhere(
        (e) => e.name == ball,
        orElse: () => BallType.cricket,
      );
    }
  }

  @override
  void dispose() {
    teamNameCtrl.dispose();
    locationCtrl.dispose();
    slotCountCtrl.dispose();
    templateCtrl.dispose();
    rulesCtrl.dispose();
    entryFeeCtrl.dispose();
    locationDetailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          winningDate = picked;
        }
      });
    }
  }

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate()) return;

    if (startDate == null || winningDate == null) {
      setState(() => error = "Please select start and winning date");
      return;
    }
    final confirmPayment = await _showUpiQrDialog();
    if (confirmPayment != true) return;

    setState(() => isLoading = true);

    final created = await AuthService.createTournament(
      sportsCategoryId: 1,
      teamName: teamNameCtrl.text,
      location: locationCtrl.text,
      locationDetails: locationDetailsCtrl.text,
      startDate: startDate!.toIso8601String().split('T')[0],
      winningDate: winningDate!.toIso8601String().split('T')[0],
      slotCount: int.parse(slotCountCtrl.text),
      template: templateCtrl.text,
      rules: rulesCtrl.text,
      entryFee: int.parse(entryFeeCtrl.text),
      priceDetails: "Price breakdown",
      ballType: selectedBallType.name,
    );

    setState(() => isLoading = false);

    if (created != null && mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.tournamentPreview,
        arguments: created,
      );
    } else if (mounted) {
      setState(() => error = "Failed to create tournament");
    }
  }

  Future<bool?> _showUpiQrDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pay Before Create'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Scan the QR and complete payment to continue.',
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
            const SelectableText(
              'UPI ID: $_upiId',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  /// Build a map of current form data for preview (no id = not yet saved).
  Map<String, dynamic> _getPreviewData() {
    return {
      'team_name': teamNameCtrl.text,
      'location': locationCtrl.text,
      'location_details': locationDetailsCtrl.text,
      'start_date': startDate?.toIso8601String().split('T')[0],
      'winning_date': winningDate?.toIso8601String().split('T')[0],
      'slot_count': slotCountCtrl.text.isEmpty
          ? 0
          : int.tryParse(slotCountCtrl.text),
      'template': templateCtrl.text,
      'rules': rulesCtrl.text,
      'entry_fee': entryFeeCtrl.text.isEmpty
          ? 0
          : int.tryParse(entryFeeCtrl.text),
      'ball_type': selectedBallType.name,
    };
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _dateField(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, filled: true),
        child: Text(
          date != null ? "${date.day}/${date.month}/${date.year}" : label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const AppHeader(
        title: AppStrings.createTournament,
        showBack: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ErrorMessage(
                    message: error,
                    onDismiss: () => setState(() => error = ""),
                  ),

                  /// BASIC INFO
                  _sectionCard(
                    title: "Basic Information",
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: teamNameCtrl,
                          label: AppStrings.teamName,
                          validator: (v) => Validators.required(
                            v?.trim(),
                            fieldName: AppStrings.teamName,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: locationCtrl,
                          label: AppStrings.location,
                          validator: (v) => Validators.required(
                            v?.trim(),
                            fieldName: AppStrings.location,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: locationDetailsCtrl,
                          label: AppStrings.locationDetails,
                          maxLines: 2,
                          validator: (v) => Validators.required(
                            v?.trim(),
                            fieldName: AppStrings.locationDetails,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// DATE SECTION
                  _sectionCard(
                    title: "Tournament Schedule",
                    child: Row(
                      children: [
                        Expanded(
                          child: _dateField(
                            AppStrings.startDate,
                            startDate,
                            () => _selectDate(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dateField(
                            AppStrings.endDate,
                            winningDate,
                            () => _selectDate(false),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// MATCH SETTINGS
                  _sectionCard(
                    title: "Match Settings",
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: slotCountCtrl,
                          label: AppStrings.slotCount,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final val = v?.trim() ?? '';
                            if (val.isEmpty)
                              return '${AppStrings.slotCount} required';
                            final parsed = int.tryParse(val);
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid slot count';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<BallType>(
                          value: selectedBallType,
                          decoration: const InputDecoration(
                            labelText: AppStrings.ballType,
                            filled: true,
                          ),
                          items: BallType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => selectedBallType = v!),
                        ),
                      ],
                    ),
                  ),

                  /// RULES SECTION
                  _sectionCard(
                    title: "Rules & Template",
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: templateCtrl,
                          label: AppStrings.template,
                          maxLines: 3,
                          validator: (v) => Validators.required(
                            v?.trim(),
                            fieldName: AppStrings.template,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: rulesCtrl,
                          label: AppStrings.rules,
                          maxLines: 4,
                          validator: (v) => Validators.required(
                            v?.trim(),
                            fieldName: AppStrings.rules,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ENTRY FEE
                  _sectionCard(
                    title: "Entry Details",
                    child: CustomTextField(
                      controller: entryFeeCtrl,
                      label: AppStrings.entryFee,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final val = v?.trim() ?? '';
                        if (val.isEmpty)
                          return '${AppStrings.entryFee} required';
                        final parsed = int.tryParse(val);
                        if (parsed == null || parsed < 0) {
                          return 'Enter a valid entry fee';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.saveDraft,
                          isOutlined: true,
                          onPressed: _createTournament,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.previewTournament,
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) return;
                            if (startDate == null || winningDate == null) {
                              setState(
                                () => error =
                                    "Please select start and winning date",
                              );
                              return;
                            }
                            Navigator.pushNamed(
                              context,
                              AppRoutes.tournamentPreview,
                              arguments: _getPreviewData(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          AppLoader(isLoading: isLoading),
        ],
      ),
    );
  }
}
