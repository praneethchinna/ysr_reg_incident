import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginApi {
  final Dio _dio;
  LoginApi(this._dio);
  Future<LoginResponse> loginIncident({
    required String mobile,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login-incident',
        data: {
          'mobile': mobile,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromMap(response.data);
      } else {
        // Any non-200 response
        throw Exception("Login failed");
      }
    } on DioException catch (_) {
      // Handle all Dio-related errors
      throw Exception("Login failed");
    } catch (_) {
      // Catch all other exceptions
      throw Exception("Login failed");
    }
  }

  Future<bool> generateOtpIncident({required String mobile}) async {
    final response = await _dio.post(
      '/generate-otp-incident',
      data: {
        'mobile': mobile,
      },
    );

    try {
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to generate OTP:');
      }
    } on DioException {
      throw Exception('Failed to generate OTP:');
    } catch (_) {
      throw Exception('Failed to generate OTP: ');
    }
  }

  Future<bool> verifyOtpIncident({
    required String mobile,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/verify-otp-incident',
        data: {
          'mobile': mobile,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Failed to verify OTP");
      }
    } on DioException {
      throw Exception("Failed to verify OTP");
    } catch (_) {
      throw Exception("Failed to verify OTP");
    }
  }
}

class LoginResponse {
  final String message;
  final int userId;
  final String name;
  final String role;
  final String mobile;
  final String parliament;
  final String constituency;
  final String gender;
  final String email;
  final bool blocked;

  LoginResponse({
    required this.message,
    required this.userId,
    required this.name,
    required this.role,
    required this.mobile,
    required this.parliament,
    required this.constituency,
    required this.gender,
    required this.email,
    required this.blocked,
  });

  factory LoginResponse.fromMap(Map<String, dynamic> json) => LoginResponse(
        message: json['message'] ?? '',
        userId: json['user_id'] ?? 0,
        name: json['name'] ?? '',
        role: json['role'] ?? '',
        mobile: json['mobile'] ?? '',
        parliament: json['parliament'] ?? '',
        constituency: json['constituency'] ?? '',
        gender: json['gender'] ?? '',
        email: json['email'] ?? '',
        blocked: json['blocked'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'user_id': userId,
        'name': name,
        'role': role,
        'mobile': mobile,
        'parliament': parliament,
        'constituency': constituency,
        'gender': gender,
        'email': email,
        'blocked': blocked,
      };
}

final loginResponseProvider = StateProvider<LoginResponse?>((ref) => null);
