enum MenuCategory { drinks, food }

class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.isDrink,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      isDrink: json['isDrink'] as bool,
    );
  }

  final String id;
  final String name;
  final double price;
  final bool isDrink;
}

class MenuSnapshot {
  const MenuSnapshot({required this.menuHash, required this.items});

  factory MenuSnapshot.fromJson(Map<String, dynamic> json) {
    return MenuSnapshot(
      menuHash: json['menuHash'] as String,
      items: [
        ...json['foodItems'] as List<dynamic>,
        ...json['drinkItems'] as List<dynamic>,
      ].map((item) => MenuItem.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  final String menuHash;
  final List<MenuItem> items;
}
