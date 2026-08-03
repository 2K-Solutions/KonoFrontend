class AuthResult {
  const AuthResult({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.userId,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      userId: json['userId'] as String?,
    );
  }

  final bool success;
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
}
