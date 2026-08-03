import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/network/dio_provider.dart';
import 'package:konofrontend/features/auth/domain/auth_result.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return DioAuthRepository(ref.watch(dioProvider));
});

abstract class AuthRepository {
  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String secondName,
    required String phoneNumber,
  });

  Future<AuthResult> login({
    required String email,
    required String password,
  });
}

class DioAuthRepository implements AuthRepository {
  DioAuthRepository(this._dio);

  final Dio _dio;

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String secondName,
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
          'username': username,
          'firstName': firstName,
          'secondName': secondName,
          'phoneNumber': phoneNumber,
          'userRole': 1,
        },
      );
      return AuthResult.fromJson(response.data!);
    } on DioException catch (error) {
      return AuthResult(success: false, message: _messageFrom(error));
    }
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthResult.fromJson(response.data!);
    } on DioException catch (error) {
      return AuthResult(success: false, message: _messageFrom(error));
    }
  }

  String _messageFrom(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    return 'Something went wrong. Please try again.';
  }
}
