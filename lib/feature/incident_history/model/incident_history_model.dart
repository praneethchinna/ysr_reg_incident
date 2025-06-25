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
      incidentId: json['incident_id'] as int,
      name: json['name'] as String,
      gender: json['gender'] as String,
      mobile: json['mobile'] as String,
      email: json['email'] as String?,
      parliament: json['parliament'] as String,
      assembly: json['assembly'] as String,
      incidentType: json['incident_type'] as String,
      incidentPlace: json['incident_place'] as String,
      incidentDate: json['incident_date'] as String,
      incidentTime: json['incident_time'] as String,
      incidentDescription: json['incident_description'] as String,
      incidentProofPaths: json['incident_proof_paths'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      statusReason: json['status_reason'] as String?,
    );
  }
}
