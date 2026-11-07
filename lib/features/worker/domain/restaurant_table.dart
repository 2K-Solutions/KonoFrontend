class RestaurantTable {
  const RestaurantTable({required this.id, required this.number});

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] as String,
      number: (json['tableNumber'] as num).toInt(),
    );
  }

  final String id;
  final int number;
}
