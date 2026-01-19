import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:food2/core/constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final CancelToken _cancelToken = CancelToken();

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          final token = _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            print('🌐 API Request: ${options.method} ${options.path}');
            if (options.data != null) {
              print('📦 Request Body: ${options.data}');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
            print('Error: ${error.message}');
          }
          return handler.next(error);
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print(object.toString()),
      ));
    }
  }

  String? _getAuthToken() {
    // Get token from secure storage
    // Implement your token storage logic here
    return null;
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: _cancelToken,
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: _cancelToken,
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: _cancelToken,
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: _cancelToken,
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> uploadFile(
      String path,
      File file, {
        String fieldName = 'file',
        Map<String, dynamic>? data,
        void Function(int, int)? onSendProgress,
      }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        ...?data,
      });

      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: _cancelToken,
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      throw Exception('Connection timeout. Please check your internet connection.');
    } else if (e.type == DioExceptionType.receiveTimeout) {
      throw Exception('Receive timeout. Please try again.');
    } else if (e.type == DioExceptionType.sendTimeout) {
      throw Exception('Send timeout. Please try again.');
    } else if (e.type == DioExceptionType.badResponse) {
      final response = e.response;
      if (response != null) {
        final statusCode = response.statusCode;
        final errorData = response.data;

        switch (statusCode) {
          case 400:
            throw Exception(_parseErrorMessage(errorData) ?? 'Bad request.');
          case 401:
            throw Exception('Unauthorized. Please login again.');
          case 403:
            throw Exception('Access forbidden.');
          case 404:
            throw Exception('Resource not found.');
          case 422:
            throw Exception(_parseValidationErrors(errorData) ?? 'Validation failed.');
          case 500:
            throw Exception('Server error. Please try again later.');
          case 502:
            throw Exception('Bad gateway.');
          case 503:
            throw Exception('Service unavailable.');
          default:
            throw Exception('An error occurred (Status: $statusCode).');
        }
      }
    } else if (e.type == DioExceptionType.cancel) {
      throw Exception('Request cancelled.');
    } else if (e.type == DioExceptionType.unknown) {
      if (e.error is SocketException) {
        throw Exception('No internet connection.');
      }
      throw Exception('An unknown error occurred.');
    }
  }

  String? _parseErrorMessage(dynamic errorData) {
    try {
      if (errorData is Map<String, dynamic>) {
        return errorData['message']?.toString();
      } else if (errorData is String) {
        final decoded = jsonDecode(errorData);
        if (decoded is Map<String, dynamic>) {
          return decoded['message']?.toString();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing error message: $e');
      }
    }
    return null;
  }

  String? _parseValidationErrors(dynamic errorData) {
    try {
      if (errorData is Map<String, dynamic>) {
        final errors = errorData['errors'];
        if (errors is Map<String, dynamic>) {
          final errorMessages = errors.values
              .expand((error) => (error as List<dynamic>).cast<String>())
              .toList();
          return errorMessages.join(', ');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing validation errors: $e');
      }
    }
    return null;
  }

  void cancelRequests() {
    _cancelToken.cancel('Request cancelled by user');
  }

  void updateAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic) fromJsonT,
      ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      statusCode: json['status_code'],
      errors: json['errors'],
    );
  }
}