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
  final String complaineeName;
  final String complaineeDesignation;

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
   required  this.complaineeName,
    required this.complaineeDesignation ,
  });

  factory IncidentDetailsModel.fromJson(Map<String, dynamic> json) {
    return IncidentDetailsModel(
      incidentId: json['incident_id'] ?? 0,
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email']?.isNotEmpty == true ? json['email'] : '',
      parliament: json['parliament'] ?? '',
      assembly: json['assembly'] ?? '',
      incidentType: json['incident_type'] ?? '',
      incidentPlace: json['incident_place'] ?? '',
      incidentDate: json['incident_date'] ?? '',
      incidentTime: json['incident_time'] ?? '',
      incidentDescription: json['incident_description'] ?? '',
      idProofType: json['id_proof_type']?.isNotEmpty == true ? json['id_proof_type'] : '',
      idProofPath: json['id_proof_path']?.isNotEmpty == true ? json['id_proof_path'] : '',
      selfiePath: json['selfie_path']?.isNotEmpty == true ? json['selfie_path'] : '',
      incidentProofPaths: json['incident_proof_paths'] != null
          ? json['incident_proof_paths']?.isNotEmpty == true ? [json['incident_proof_paths']] : []
          : [],
      status: json['status'] ?? '',
      statusReason: json['status_reason']?.isNotEmpty == true ? json['status_reason'] : '',
      createdAt: json['created_at'] ?? '',
      userId: json['user_id'] ?? 0,
      complaineeName: json['complainee_name'] ?? '',
      complaineeDesignation: json['complainee_designation'] ?? '',
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
