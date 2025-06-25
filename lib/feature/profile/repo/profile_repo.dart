import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ysr_reg_incident/feature/profile/model/profile_response_model.dart';
import 'package:ysr_reg_incident/services/dio_provider.dart';

final profileRepoProvider = Provider<ProfileRepo>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileRepo(dio);
});

class ProfileRepo {
  final Dio _dio;

  ProfileRepo(this._dio);

  Future<ProfileResponseModel> getProfileIncident(String mobile) async {
    final response = await _dio.get(
      '/user/profile-incident',
      queryParameters: {
        'mobile': mobile,
      },
    );

    if (response.statusCode == 200) {
      return ProfileResponseModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load profile incident');
    }
  }

  Future<bool> updateProfileIncident({
    required String mobile,
    required String name,
    required String gender,
    required String country,
    required String state,
    required String parliament,
    required String constituency,
    required String email,
  }) async {
    final response = await _dio.put(
      '/user/update-profile-incident',
      queryParameters: {
        'mobile': mobile,
      },
      data: {
        'name': name,
        'gender': gender,
        'country': country,
        'state': state,
        'parliament': parliament,
        'constituency': constituency,
        'email': email,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update profile incident');
    }
  }
}
