import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../models/tournament_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/error_message.dart';

class CreateTournament extends StatefulWidget {
  final TournamentModel? tournament; // For editing

  const CreateTournament({super.key, this.tournament});

  @override
  State<CreateTournament> createState() => _CreateTournamentState();
}

class _CreateTournamentState extends State<CreateTournament> {
  final _formKey = GlobalKey<FormState>();
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
    if (widget.tournament != null) {
      // Populate fields for editing
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (startDate ?? DateTime.now()) : (winningDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          winningDate = picked;
        }
      });
    }
  }

  void _saveDraft() {
    // Save as draft logic
    Navigator.pushNamed(context, AppRoutes.tournamentPreview);
  }

  void _preview() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (startDate == null || winningDate == null) {
      setState(() {
        error = 'Please select start date and winning date';
      });
      return;
    }
    Navigator.pushNamed(context, AppRoutes.tournamentPreview);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ErrorMessage(
                    message: error,
                    onDismiss: () => setState(() => error = ""),
                  ),
                  CustomTextField(
                    controller: teamNameCtrl,
                    label: AppStrings.teamName,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: locationCtrl,
                    label: AppStrings.location,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppStrings.startDate,
                              filled: true,
                            ),
                            child: Text(
                              startDate != null
                                  ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                                  : 'Select Start Date',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppStrings.winningDate,
                              filled: true,
                            ),
                            child: Text(
                              winningDate != null
                                  ? '${winningDate!.day}/${winningDate!.month}/${winningDate!.year}'
                                  : 'Select Winning Date',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: slotCountCtrl,
                    label: AppStrings.slotCount,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: templateCtrl,
                    label: AppStrings.template,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: rulesCtrl,
                    label: AppStrings.rules,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: entryFeeCtrl,
                    label: AppStrings.entryFee,
                    keyboardType: TextInputType.number,
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
                        child: Text(type.toString().split('.').last.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedBallType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: locationDetailsCtrl,
                    label: AppStrings.locationDetails,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.saveDraft,
                          isOutlined: true,
                          onPressed: _saveDraft,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.previewTournament,
                          onPressed: _preview,
                        ),
                      ),
                    ],
                  ),
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

