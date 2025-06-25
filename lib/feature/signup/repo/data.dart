import 'package:dio/dio.dart';

class SignupIncidentData {
  final Dio _dio;

  SignupIncidentData(this._dio);

  Future<bool> signupIncident({
    required String name,
    required String gender,
    required String country,
    required String state,
    required int parliament,
    required int constituency,
    required String mobile,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/signup-incident',
        data: {
          'name': name,
          'gender': gender,
          'country': country,
          'state': state,
          'parliament': parliament,
          'constituency': constituency,
          'mobile': mobile,
          'email': email,
          'password': password,
          'referral_code': "",
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Any non-200 response
        throw Exception("Signup failed");
      }
    } on DioException catch (e) {
      // Handle all Dio-related errors
      throw Exception(
          "Signup failed ${e.response?.data["detail"].first["msg"]}");
    } catch (_) {
      // Catch all other exceptions
      throw Exception("Signup failed");
    }
  }
}
