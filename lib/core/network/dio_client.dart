import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Singleton Dio client configured for the Pexels API.
class DioClient {
  DioClient._();
  static final DioClient _instance = DioClient._();
  static DioClient get instance => _instance;

  late final Dio _dio;

  Dio get dio => _dio;

  /// Must be called once before using the client.
  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.pexelsBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // ── API Key Interceptor ────────────────────────────────────────────
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = AppConstants.pexelsApiKey;
          handler.next(options);
        },
      ),
    );

    // ── Logging Interceptor (debug only) ───────────────────────────────
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (obj) => debugPrint('🌐 $obj'),
        ),
      );
    }
  }
}
