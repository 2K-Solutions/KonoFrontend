import 'package:dio/dio.dart';

// The backend answers errors either with {"message": "..."} or with a bare string body.
String apiErrorMessage(Object error, {String fallback = 'Something went wrong. Please try again.'}) {
  if (error is! DioException) return fallback;
  final data = error.response?.data;
  if (data is Map<String, dynamic> && data['message'] is String) return data['message'] as String;
  if (data is String && data.isNotEmpty && data.length < 200 && !data.trimLeft().startsWith('<')) {
    return data;
  }
  return fallback;
}
