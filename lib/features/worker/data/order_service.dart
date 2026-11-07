import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/features/worker/data/menu_database.dart';
import 'package:konofrontend/features/worker/data/order_repository.dart';
import 'package:konofrontend/features/worker/domain/order.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.watch(orderRepositoryProvider), ref.watch(menuDatabaseProvider));
});

class OrderService {
  OrderService(this._repository, this._menuDatabase);

  final OrderRepository _repository;
  final MenuDatabase _menuDatabase;

  Future<Order?> findOrderForTable(String tableId) async {
    final orders = await _repository.getMyOrders();
    return orders.where((order) => order.isActive && order.tableId == tableId).firstOrNull;
  }

  // The backend has one order per table and no separate bar/kitchen queue: sending adds the
  // lines to the table's open order, creating it if the table has none yet.
  Future<void> sendToTable({required String tableId, required List<OrderLine> lines}) async {
    final existing = await findOrderForTable(tableId);
    if (existing == null) {
      await _repository.createOrder(tableId: tableId, lines: lines);
      return;
    }

    final items = await _repository.getOrderItems(existing.id);
    await _repository.editOrder(
      orderId: existing.id,
      tableId: tableId,
      lines: [...items.map((item) => _lineFrom(item, null)), ...lines],
    );
  }

  // The backend only returns menu item ids, so names come from the locally synced menu.
  Future<List<OrderLine>> loadOrderLines(String orderId) async {
    final items = await _repository.getOrderItems(orderId);
    final menu = await _menuDatabase.getByIds(items.map((item) => item.menuItemId));
    return [for (final item in items) _lineFrom(item, menu[item.menuItemId]?.name)];
  }

  OrderLine _lineFrom(OrderItem item, String? name) {
    return OrderLine(
      menuItemId: item.menuItemId,
      name: name ?? 'Unknown item',
      isDrink: item.isDrink,
      quantity: item.quantity,
      description: item.description,
    );
  }
}
