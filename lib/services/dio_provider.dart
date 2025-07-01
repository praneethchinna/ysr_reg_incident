import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:ysr_reg_incident/main.dart';

final dioProvider = Provider<Dio>((ref) {
  final logger = PrettyDioLogger(
    enabled: kDebugMode,
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: true,
    error: true,
    compact: true,
    maxWidth: 90,
    logPrint: (s) => log(s.toString()),
    filter: (options, args) {
      return !args.isResponse || !args.hasUint8ListData;
    },
  );

  return Dio(BaseOptions(
    baseUrl: 'http://3.82.180.105:8000/api',
    connectTimeout: const Duration(seconds: 20), // Connection timeout
    receiveTimeout: const Duration(seconds: 20), // Response timeout
    headers: {
      'Accept': '*/*',
    }, // Default headers
  ))
    ..interceptors.addAll([
      logger,
      GlobalErrorInterceptor(),
    ]);
});

class GlobalErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      showGlobalNetworkDialog("Check your connection and try again.");
      return handler.reject(
        DioException(
          message: "Check your connection and try again.",
          requestOptions: err.requestOptions,
        ),
      );
    }

    super.onError(err, handler); // always call this to continue the chain
  }
}

class AppNetworkException implements Exception {
  final String message;

  AppNetworkException(this.message);

  @override
  String toString() => message;
}

void showGlobalNetworkDialog(String message) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Network Error"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("Cancel"),
        ),
      ],
    ),
  );
}
