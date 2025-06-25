import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ysr_reg_incident/feature/incident_history/model/incident_details_model.dart';
import 'package:ysr_reg_incident/feature/incident_history/model/incident_history_model.dart';

class IncidentHistoryRepository {
  final Dio _dio;

  IncidentHistoryRepository(this._dio);

  Future<List<IncidentHistoryModel>> getIncidentHistory(String userId) async {
    try {
      final response = await _dio.get('/incidents', queryParameters: {
        'user_id': userId,
      });

      if (response.statusCode == 200) {
        return (response.data["data"] as List)
            .map((item) => IncidentHistoryModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load incident history');
      }
    } catch (e) {
      throw Exception('Error fetching incident history: $e');
    }
  }

  Future<MainIncidentModel> getIncidentDetails(int incidentId) async {
    try {
      final response = await _dio.get('/incident/$incidentId');

      if (response.statusCode == 200) {
        return MainIncidentModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load incident details');
      }
    } catch (e) {
      throw Exception('Error fetching incident details: $e');
    }
  }

  Future<List<String>> getIncidentProofFiles(int incidentId) async {
    try {
      final response = await _dio.get('/incident-proof-files/$incidentId');

      if (response.statusCode == 200) {
        return List<String>.from(
            response.data?.map((e) => e["file_path"]) ?? <String>[]);
      } else {
        throw Exception('Failed to load incident proof files');
      }
    } catch (e) {
      throw Exception('Error fetching incident proof files: $e');
    }
  }

  Future<List<HistoryModel>> getIncidentHistoryStatus(int incidentId) async {
    // return jsonDecode(dummy)
    //     .map<HistoryModel>((json) => HistoryModel.fromJson(json))
    //     .toList();
    try {
      final response = await _dio.get('/incidents/$incidentId/history');

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => HistoryModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load incident history');
      }
    } catch (e) {
      throw Exception('Error fetching incident history: $e');
    }
  }
}

const dummy = '''[
  {
    "incident_id": 68,
    "status": "Open",
    "remarks": "Incident Received",
    "updated_at": "2025-06-24T06:59:11.678425"
  },
  {
    "incident_id": 68,
    "status": "Pending",
    "remarks": "Assigned to officer",
    "updated_at": "2025-06-24T08:20:15.112345"
  },
  {
    "incident_id": 68,
    "status": "In Progress",
    "remarks": "Investigation ongoing",
    "updated_at": "2025-06-24T10:45:00.000000"
  },
  {
    "incident_id": 68,
    "status": "Resolved",
    "remarks": "Issue resolved, report filed",
    "updated_at": "2025-06-24T13:30:45.987654"
  },
  {
    "incident_id": 68,
    "status": "Closed",
    "remarks": "Incident closed by supervisor",
    "updated_at": "2025-06-24T15:00:00.123456"
  }
]
''';
