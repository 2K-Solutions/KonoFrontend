class RestaurantInvite {
  const RestaurantInvite({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.expiresAt,
  });

  factory RestaurantInvite.fromJson(Map<String, dynamic> json) {
    return RestaurantInvite(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      restaurantName: json['restaurantName'] as String,
      expiresAt: _parseUtc(json['expiresAt'] as String),
    );
  }

  static DateTime _parseUtc(String value) {
    final parsed = DateTime.parse(value);
    if (parsed.isUtc) return parsed;
    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    );
  }

  final String id;
  final String restaurantId;
  final String restaurantName;
  final DateTime expiresAt;
}
