class InviteActionResult {
  const InviteActionResult({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
  });

  final bool success;
  final String message;
  final String? accessToken;
  final String? refreshToken;
}
