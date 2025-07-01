import 'package:dio/dio.dart';

class ForgotPasswordRepo {
  final Dio _dio;

  ForgotPasswordRepo(this._dio);

  Future<String> forgotPassword(String mobile) async {
    try {
      final response = await _dio
          .post('/forgot-password-otp-incident', data: {'mobile': mobile});
      if (response.statusCode == 200) {
        return response.data['message'];
      } else {
        throw Exception('Failed to get OTP');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get OTP: ${e.message}');
    }
  }

  Future<bool> verifyOtp(String mobile, String otp) async {
    try {
      final response = await _dio.post('/verify-forgot-password-otp-incident',
          data: {'mobile': mobile, 'otp': otp});
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to verify OTP');
      }
    } on DioException catch (e) {
      throw Exception('Failed to verify OTP: ${e.message}');
    }
  }

  Future<String> resetPassword(String mobile, String password) async {
    try {
      final response = await _dio.post('/reset-password-incident',
          data: {'mobile': mobile, 'new_password': password});
      if (response.statusCode == 200) {
        return response.data['message'];
      } else {
        throw Exception('Failed to reset password');
      }
    } on DioException catch (e) {
      throw Exception('Failed to reset password: ${e.message}');
    }
  }
}
