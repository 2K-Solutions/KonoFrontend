import 'package:konofrontend/core/network/jwt_claims.dart';

class AuthResult {
  const AuthResult({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.userId,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'] as String?;
    return AuthResult(
      success: json['success'] as bool? ?? (accessToken != null && accessToken.isNotEmpty),
      message: json['message'] as String? ?? '',
      accessToken: accessToken,
      refreshToken: json['refreshToken'] as String?,
      userId: json['userId'] as String?,
    );
  }

  final bool success;
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final String? userId;

  String? get accountType => decodeJwtPayload(accessToken)?['accountType'] as String?;
}
