class Restaurant {
  const Restaurant({required this.id, required this.name});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  final String id;
  final String name;
}
