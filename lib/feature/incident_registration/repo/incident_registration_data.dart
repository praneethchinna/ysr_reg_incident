import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:ysr_reg_incident/feature/incident_registration/provider/incident_registration_provider.dart';

class IncidentRegistrationData {
  final Dio _dio;

  IncidentRegistrationData(this._dio);

  Future<List<IncidentTypes>> getIncidentCategories(String language) async {
    try {
      final response = await _dio.get('/incident-categories?lang=$language');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => IncidentTypes.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load incident categories');
      }
    } catch (e) {
      throw Exception('Error fetching incident categories: $e');
    }
  }

  Future<int?> submitIncident({
    required String? emailId,
    required int? userId,
    required String name,
    required String? gender,
    required String? mobile,
    required String parliament,
    required String assembly,
    required String incidentType,
    required String incidentPlace,
    required String incidentDate,
    required String incidentTime,
    required String incidentDescription,
    required String idProofType,
    required List<PlatformFile> incidentProofs,
    required String mandal,
    required String village,
    required String complaineeName,
    required String complaineeDesignation,
    required File? incidentExplanation,
  }) async {
    try {
      final formData = FormData.fromMap({
        "user_id": userId.toString(),
        "email": emailId,
        "name": name,
        "gender": gender,
        "mobile": mobile,
        "parliament": parliament,
        "assembly": assembly,
        "incident_type": incidentType,
        "incident_place": incidentPlace,
        "incident_date": incidentDate,
        "incident_time": incidentTime,
        "incident_description": incidentDescription,
        "id_proof_type": idProofType,
        "mandal_name": mandal,
        "village_name": village,
        "complainee_name": complaineeName,
        "complainee_designation": complaineeDesignation,
        "incident_video": incidentExplanation == null
            ? null
            : await MultipartFile.fromFile(incidentExplanation.path,
                filename: incidentExplanation.path.split('/').last),
      });

      for (var file in incidentProofs) {
        final multipartFile = await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        );
        formData.files.add(MapEntry('incident_proofs', multipartFile));
      }

      final response =
          await _dio.post('/submit-incident-mobile', data: formData);

      if (response.statusCode == 200) {
        return response.data['user_id'];
      } else {
        throw Exception('Failed to submit incident: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Dio error: ${e.response?.statusCode} - ${e.response?.data}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
