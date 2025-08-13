import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:video_compress/video_compress.dart';
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

  // Future<XFile?> compressImage(File file) async {
  //   final dir = await getTemporaryDirectory();
  //   EasyLoading.show(status: 'Compressing image...');
  //   final targetPath =
  //       '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
  //
  //   try {
  //     var result = await FlutterImageCompress.compressAndGetFile(
  //       file.absolute.path,
  //       targetPath,
  //       quality: 88,
  //     );
  //     return result;
  //   } catch (e) {
  //     EasyLoading.dismiss();
  //     throw Exception('Error compressing image: $e');
  //   }
  // }
  //
  // Future<MediaInfo?> compressVideo(File filePath) async {
  //   // Optional: show compression progress
  //   // VideoCompress.compressProgress$.subscribe((progress) {
  //   //   EasyLoading.showProgress(progress, status: 'Compressing video...');
  //   // });
  //
  //   try {
  //     MediaInfo? info = await VideoCompress.compressVideo(
  //       filePath.path,
  //       quality: VideoQuality.MediumQuality,
  //       deleteOrigin: false, // keep original
  //
  //     );
  //
  //     return info;
  //   } on Exception catch (e) {
  //     await VideoCompress.deleteAllCache();
  //     EasyLoading.dismiss();
  //     throw Exception('Error compressing video: $e');
  //   }
  // }
  //
  // Future<MultipartFile> incidentProof(File file) async {
  //   final compressedVideo = await compressVideo(File(file.path));
  //   MultipartFile multipartFile =
  //       await setFilePathsForVideos(compressedVideo!.path.toString());
  //   return multipartFile;
  // }

  Future<bool> uploadFiles({required List<UploadUrls> urls}) async {
    try {
      for (var url in urls) {
        final response = await Dio().putUri(
          Uri.parse(url.uploadUrl),
          data: File(url.filePath).readAsBytesSync(),
          options: Options(
            headers: {
              'Content-Type':
                  "${_switchFileType(url.filePath.split('.').last)}/${url.filePath.split('.').last}",
            },
          ),
        );
        if (response.statusCode != 200) {
          log('Error uploading file: ${response.statusMessage}');
          throw Exception('Error uploading file: ${response.statusMessage}');
        }
        if (response.statusCode == 200) {}
      }
      return true;
    } catch (e) {
      log('Error uploading file: $e');
      throw Exception('Error uploading file: $e');
    }
  }

  Future<List<UploadUrls>> generateMultipleFiles(
      List<File> incidentProofs, File incidentExplanation) async {
    try {
      List<GenerateUploadUrls> files = incidentProofs.map((e) {
        return GenerateUploadUrls(
          fileName: e.path.split('/').last,
          contentType:
              "${_switchFileType(e.path.split('.').last)}/${e.path.split('.').last}",
          folder: 'incident_proofs',
        );
      }).toList();
      files.add(GenerateUploadUrls(
        fileName: incidentExplanation.path.split('/').last ?? '',
        contentType:
            "${_switchFileType(incidentExplanation.path.split('.').last)}/${incidentExplanation.path.split('.').last}",
        folder: 'video_proofs',
      ));
      final response = await _dio.post('/generate-multiple-upload-urls',
          data: files.map((e) => e.toJson()).toList());
      switch (response.statusCode) {
        case 200:
          List<UploadUrls> urls =
              (response.data['upload_urls'] as List).map((item) {
            if (item["upload_url"].contains("incident_proofs")) {
              final matchedFile = incidentProofs.firstWhere(
                (file) => item['file_url'].contains(file.path.split('/').last),
              );
              return UploadUrls.fromJson(
                  item, matchedFile.path, "incident_proofs");
            } else {
              return UploadUrls.fromJson(
                  item, incidentExplanation.path, "video_proofs");
            }
          }).toList();

          return urls;
        case 206:
          throw Exception('206 Partial Content');
        case 400:
          throw Exception('400 Bad Request');
        case 403:
          throw Exception('403 Forbidden');
        case 404:
          throw Exception('404 Not Found');
        case 405:
          throw Exception('405 Method Not Allowed');
        case 416:
          throw Exception('416 Requested Range Not Satisfiable');
        case 500:
          throw Exception('500 Internal Server Error');
        case 503:
          throw Exception('503 Service Unavailable');
        default:
          throw Exception('Unknown error');
      }
    } on DioError catch (e) {
      throw Exception('Error generating multiple upload urls: ${e.message}');
    } catch (e) {
      throw Exception('Error generating multiple upload urls: $e');
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
    // required List<PlatformFile> incidentProofs,
    required String mandal,
    required String village,
    required String complaineeName,
    required String complaineeDesignation,
    required List<String> incidentProofsUrls,
    required String incidentVideoUrl,
    // required File? incidentExplanation,
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
        "incident_proof_urls": incidentProofsUrls.join(","),
        "incident_video_url": incidentVideoUrl,
      });
      //   "incident_video": incidentExplanation == null
      //       ? null
      //       : await MultipartFile.fromFile(incidentExplanation.path,
      //           filename: incidentExplanation.path.split('/').last),
      // });
      //
      // for (var file in incidentProofs) {
      //   final multipartFile = await MultipartFile.fromFile(
      //     file.path!,
      //     filename: file.name,
      //   );
      //   formData.files.add(MapEntry('incident_proofs', multipartFile));
      // }

      final response =
          await _dio.post('/submit-incident-presigned', data: formData);

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

  // Future<MultipartFile> setFilePathsForVideos(String filePath) async {
  //   final multipartFile = await MultipartFile.fromFile(
  //     filePath,
  //     filename: filePath.split('/').last,
  //   );
  //   return multipartFile;
  // }
  //
  // Future<MultipartFile> setFilePathsForImages(XFile file) async {
  //   final multipartFile = await MultipartFile.fromFile(
  //     file.path,
  //     filename: file.path.split('/').last,
  //   );
  //   return multipartFile;
  // }
  //
  // Future<MultipartFile> setFilePaths(PlatformFile file) async {
  //   final multipartFile = await MultipartFile.fromFile(
  //     file.path!,
  //     filename: file.name,
  //   );
  //   return multipartFile;
  // }
}

String _switchFileType(String fileType) {
  switch (fileType) {
    case '.png':
    case '.jpg':
    case '.jpeg':
      return 'image';
    case '.mp4':
    case '.mov':
      return 'video';
    case '.pdf':
      return 'pdf';
    case '.mp3':
    case '.wav':
      return 'audio';
    default:
      return 'unknown';
  }
}

class UploadUrls {
  final String uploadUrl;
  final String fileUrl;
  final String filePath;
  final String fileType;

  UploadUrls(
      {required this.uploadUrl,
      required this.fileUrl,
      required this.filePath,
      required this.fileType});

  factory UploadUrls.fromJson(
      Map<String, dynamic> json, String file, String fileType) {
    return UploadUrls(
      uploadUrl: json['upload_url'],
      fileUrl: json['file_url'],
      filePath: file,
      fileType: fileType,
    );
  }
}

class GenerateUploadUrls {
  final String fileName;
  final String contentType;
  final String folder;

  GenerateUploadUrls({
    required this.fileName,
    required this.contentType,
    required this.folder,
  });

  Map<String, dynamic> toJson() {
    return {
      'file_name': fileName,
      'content_type': contentType,
      'folder': folder,
    };
  }
}
