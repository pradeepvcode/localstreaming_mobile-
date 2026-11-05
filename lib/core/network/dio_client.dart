//
// import 'package:dio/dio.dart';
//
// class DioClient {
//   DioClient._();
//
//   static const String baseUrl = 'https://bagging-underpay-plating.ngrok-free.dev';
//
//   static final Dio instance = Dio(
//     BaseOptions(
//       baseUrl: baseUrl,
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 15),
//       headers: {'Accept': 'application/json'},
//     ),
//   );
//
// }

import 'package:dio/dio.dart';

class DioClient {
  // Prevent external object creation
  DioClient._();

  static const String baseUrl = 'https://joselyn-oversolemn-myong.ngrok-free.dev';

  // Shared Dio instance
  static final Dio instance = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // 1. Logging interceptor
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );

    // 2. Additional custom interceptors can be added here
    // dio.interceptors.add(AuthInterceptor(...));

    return dio;
  }
}
