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

  Future<LoginResponse?> verifyOtpIncident({
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
        if (response.data["user_exists"] == false) {
          return null;
        }
        return LoginResponse.fromMap(response.data["user"]);
      } else {
        throw Exception("Failed to verify OTP");
      }
    } on DioException {
      throw Exception("Failed to verify OTP");
    } catch (_) {
      throw Exception("Failed to verify OTP");
    }
  }

  Future<LoginResponse?> googleSigninIncident({required String token}) async {
    try {
      final response =
          await _dio.post('/auth/email-incident', data: {"email": token});

      if (response.statusCode == 200 && response.data['user_id'] != null) {
        if (response.data["blocked"] == true) {
          throw Exception("User is blocked. Please, contact Support Team");
        }
        return LoginResponse.fromMap(response.data);
      }
      return null;
    } catch (e) {
      throw e.toString();
    }
  }
}

class LoginResponse {
  final int userId;
  final String name;
  final String gender;
  final String mobile;
  final String email;
  final String parliament;
  final String constituency;
  final String? mandalName;
  final String? villageName;
  final String state;
  final String country;

  LoginResponse({
    required this.userId,
    required this.name,
    required this.gender,
    required this.mobile,
    required this.email,
    required this.parliament,
    required this.constituency,
    this.mandalName,
    this.villageName,
    required this.state,
    required this.country,
  });

  factory LoginResponse.fromMap(Map<String, dynamic> json) => LoginResponse(
        userId: json['user_id'] ?? 0,
        name: json['name'] ?? '',
        gender: json['gender'] ?? '',
        mobile: json['mobile'] ?? '',
        email: json['email'] ?? '',
        parliament: json['parliament'] ?? '',
        constituency: json['constituency'] ?? '',
        mandalName: json['mandal_name'],
        villageName: json['village_name'],
        state: json['state'] ?? '',
        country: json['country'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'gender': gender,
        'mobile': mobile,
        'email': email,
        'parliament': parliament,
        'constituency': constituency,
        'mandal_name': mandalName,
        'village_name': villageName,
        'state': state,
        'country': country,
      };
}

final loginResponseProvider = StateProvider<LoginResponse?>((ref) => null);
