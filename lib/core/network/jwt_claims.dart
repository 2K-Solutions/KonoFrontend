import 'dart:convert';

Map<String, dynamic>? decodeJwtPayload(String? token) {
  final parts = token?.split('.');
  if (parts == null || parts.length != 3) return null;
  try {
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload) as Map<String, dynamic>;
  } on FormatException {
    return null;
  }
}
