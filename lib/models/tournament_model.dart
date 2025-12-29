enum BallType {
  cricket,
  football,
  basketball,
  tennis,
  volleyball,
  other,
}

enum TournamentStatus {
  draft,
  published,
  ongoing,
  completed,
}

class TournamentModel {
  final String id;
  final String organizationId;
  final String teamName;
  final String location;
  final DateTime startDate;
  final DateTime winningDate;
  final int slotCount;
  final String template;
  final String rules;
  final double entryFee;
  final Map<String, double> priceDetails; // e.g., {"1st": 10000, "2nd": 5000}
  final BallType ballType;
  final String locationDetails;
  final TournamentStatus status;
  final String? category;

  TournamentModel({
    required this.id,
    required this.organizationId,
    required this.teamName,
    required this.location,
    required this.startDate,
    required this.winningDate,
    required this.slotCount,
    required this.template,
    required this.rules,
    required this.entryFee,
    required this.priceDetails,
    required this.ballType,
    required this.locationDetails,
    this.status = TournamentStatus.draft,
    this.category,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json['id'].toString(),
      organizationId: json['organizationId'] ?? '',
      teamName: json['teamName'] ?? '',
      location: json['location'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      winningDate: DateTime.parse(json['winningDate']),
      slotCount: json['slotCount'] ?? 0,
      template: json['template'] ?? '',
      rules: json['rules'] ?? '',
      entryFee: (json['entryFee'] ?? 0).toDouble(),
      priceDetails: Map<String, double>.from(json['priceDetails'] ?? {}),
      ballType: BallType.values.firstWhere(
        (e) => e.toString().split('.').last == json['ballType'],
        orElse: () => BallType.other,
      ),
      locationDetails: json['locationDetails'] ?? '',
      status: TournamentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TournamentStatus.draft,
      ),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'teamName': teamName,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'winningDate': winningDate.toIso8601String(),
      'slotCount': slotCount,
      'template': template,
      'rules': rules,
      'entryFee': entryFee,
      'priceDetails': priceDetails,
      'ballType': ballType.toString().split('.').last,
      'locationDetails': locationDetails,
      'status': status.toString().split('.').last,
      'category': category,
    };
  }
}

