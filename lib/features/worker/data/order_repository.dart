import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/network/dio_provider.dart';
import 'package:konofrontend/core/network/jwt_claims.dart';
import 'package:konofrontend/core/network/token_storage.dart';
import 'package:konofrontend/features/worker/domain/order.dart';
import 'package:konofrontend/features/worker/domain/restaurant_table.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return DioOrderRepository(ref.watch(dioProvider), ref.watch(tokenStorageProvider));
});

final restaurantTablesProvider = FutureProvider.autoDispose<List<RestaurantTable>>((ref) {
  return ref.watch(orderRepositoryProvider).getTables();
});

final myOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final orders = await ref.watch(orderRepositoryProvider).getMyOrders();
  return orders.where((order) => order.isActive).toList();
});

abstract class OrderRepository {
  Future<List<RestaurantTable>> getTables();
  Future<List<Order>> getMyOrders();
  Future<List<OrderItem>> getOrderItems(String orderId);
  Future<void> createOrder({required String tableId, required List<OrderLine> lines});
  Future<void> editOrder({
    required String orderId,
    required String tableId,
    required List<OrderLine> lines,
  });
  Future<void> deleteOrder(String orderId);
}

class DioOrderRepository implements OrderRepository {
  DioOrderRepository(this._dio, this._tokenStorage);

  final Dio _dio;
  final TokenStorage _tokenStorage;

  static const _userIdClaims = [
    'nameid',
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
  ];

  Future<Map<String, dynamic>> _claims() async {
    return decodeJwtPayload(await _tokenStorage.getAccessToken()) ?? const {};
  }

  Future<String> _restaurantId() async {
    final restaurantId = (await _claims())['restaurantId'] as String?;
    if (restaurantId == null) throw StateError('You are not a member of a restaurant.');
    return restaurantId;
  }

  // The backend reads the user from the token; the route segment is only a placeholder.
  Future<String> _userId() async {
    final claims = await _claims();
    for (final key in _userIdClaims) {
      if (claims[key] is String) return claims[key] as String;
    }
    return 'me';
  }

  @override
  Future<List<RestaurantTable>> getTables() async {
    final restaurantId = await _restaurantId();
    final response = await _dio.get<List<dynamic>>('/api/Restaurants/$restaurantId/tables');
    return response.data!
        .map((json) => RestaurantTable.fromJson(json as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  @override
  Future<List<Order>> getMyOrders() async {
    final response = await _dio.get<List<dynamic>>('/api/Order/${await _userId()}/get-my-orders');
    return response.data!.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<OrderItem>> getOrderItems(String orderId) async {
    final response = await _dio.get<List<dynamic>>('/api/Order/$orderId/get-order-items');
    return response.data!.map((json) => OrderItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> createOrder({required String tableId, required List<OrderLine> lines}) async {
    await _dio.post<dynamic>(
      '/api/Order/${await _userId()}/create-order',
      data: await _orderBody(tableId, lines),
    );
  }

  @override
  Future<void> editOrder({
    required String orderId,
    required String tableId,
    required List<OrderLine> lines,
  }) async {
    await _dio.patch<dynamic>(
      '/api/Order/$orderId/edit-order-items',
      data: await _orderBody(tableId, lines),
    );
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await _dio.delete<dynamic>('/api/Order/$orderId/delete-order');
  }

  Future<Map<String, dynamic>> _orderBody(String tableId, List<OrderLine> lines) async {
    return {
      'restaurantId': await _restaurantId(),
      'tableId': tableId,
      'items': [for (final line in lines) line.toRequestJson()],
    };
  }
}
