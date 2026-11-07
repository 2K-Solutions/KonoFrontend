// An order as stored on the backend (GET /api/Order/{userId}/get-my-orders).
class Order {
  const Order({required this.id, required this.tableId, required this.isActive});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      tableId: json['tableId'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  final String id;
  final String tableId;
  final bool isActive;
}

// An item of a stored order (GET /api/Order/{orderId}/get-order-items).
class OrderItem {
  const OrderItem({
    required this.menuItemId,
    required this.isDrink,
    required this.quantity,
    required this.description,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      menuItemId: json['menuItemId'] as String,
      isDrink: json['isDrink'] as bool,
      quantity: (json['quantity'] as num).toInt(),
      description: json['itemDescription'] as String? ?? '',
    );
  }

  final String menuItemId;
  final bool isDrink;
  final int quantity;
  final String description;
}

// A line of an order being put together or edited in the app.
class OrderLine {
  const OrderLine({
    required this.menuItemId,
    required this.name,
    required this.isDrink,
    required this.quantity,
    this.description = '',
  });

  final String menuItemId;
  final String name;
  final bool isDrink;
  final int quantity;
  final String description;

  OrderLine copyWith({int? quantity, String? description}) {
    return OrderLine(
      menuItemId: menuItemId,
      name: name,
      isDrink: isDrink,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {'menuItemId': menuItemId, 'quantity': quantity, 'itemDescription': description};
  }
}
