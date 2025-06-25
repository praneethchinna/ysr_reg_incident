class MainIncidentModel {
  final IncidentDetailsModel incidentDetails;
  final List<HistoryModel> history;
  MainIncidentModel({
    required this.incidentDetails,
    required this.history,
  });

  factory MainIncidentModel.fromJson(Map<String, dynamic> json) =>
      MainIncidentModel(
        incidentDetails: IncidentDetailsModel.fromJson(json["incident"]),
        history: [],
      );
}

class IncidentDetailsModel {
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
  final String? idProofType;
  final String? idProofPath;
  final String? selfiePath;
  final List<String>? incidentProofPaths;
  final String status;
  final String? statusReason;
  final String createdAt;
  final int userId;

  IncidentDetailsModel({
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
    this.idProofType,
    this.idProofPath,
    this.selfiePath,
    this.incidentProofPaths,
    required this.status,
    this.statusReason,
    required this.createdAt,
    required this.userId,
  });

  factory IncidentDetailsModel.fromJson(Map<String, dynamic> json) {
    return IncidentDetailsModel(
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
      idProofType: json['id_proof_type'] as String?,
      idProofPath: json['id_proof_path'] as String?,
      selfiePath: json['selfie_path'] as String?,
      incidentProofPaths: json['incident_proof_paths'] != null
          ? List<String>.from(json['incident_proof_paths'] as List)
          : null,
      status: json['status'] as String,
      statusReason: json['status_reason'] as String?,
      createdAt: json['created_at'] as String,
      userId: json['user_id'] as int,
    );
  }
}

class HistoryModel {
  final int id;
  final String status;
  final String? remarks;
  final String updatedAt;

  HistoryModel({
    required this.id,
    required this.status,
    this.remarks,
    required this.updatedAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['incident_id'] as int,
      status: json['status'] as String,
      remarks: json['reason'] as String?,
      updatedAt: json['updated_at'] as String,
    );
  }
}
