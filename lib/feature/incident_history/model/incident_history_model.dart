class IncidentHistoryModel {
  final int incidentId;
  final String name;
  final String gender;
  final String mobile;
  final String? email;
  final String parliament;
  final String assembly;
  final String incidentType;
  final String incidentPlace;
  final String incidentDate;
  final String incidentTime;
  final String incidentDescription;
  final String? incidentProofPaths;
  final String status;
  final String createdAt;
  final String? statusReason;

  IncidentHistoryModel({
    required this.incidentId,
    required this.name,
    required this.gender,
    required this.mobile,
    this.email,
    required this.parliament,
    required this.assembly,
    required this.incidentType,
    required this.incidentPlace,
    required this.incidentDate,
    required this.incidentTime,
    required this.incidentDescription,
    this.incidentProofPaths,
    required this.status,
    required this.createdAt,
    this.statusReason,
  });

  factory IncidentHistoryModel.fromJson(Map<String, dynamic> json) {
    return IncidentHistoryModel(
      incidentId: json['incident_id'] ?? 0,
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] as String?,
      parliament: json['parliament'] ?? '',
      assembly: json['assembly'] ?? '',
      incidentType: json['incident_type'] ?? '',
      incidentPlace: json['incident_place'] ?? '',
      incidentDate: json['incident_date'] ?? '',
      incidentTime: json['incident_time'] ?? '',
      incidentDescription: json['incident_description'] ?? '',
      incidentProofPaths: json['incident_proof_paths'] as String?,
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      statusReason: json['status_reason'] as String?,
    );
  }
}
