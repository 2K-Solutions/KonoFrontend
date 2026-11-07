import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/features/worker/domain/menu_item.dart';
import 'package:konofrontend/features/worker/domain/order.dart';
import 'package:konofrontend/features/worker/domain/restaurant_table.dart';

// Key of the order the worker is currently taking; any other key is the id of an order being edited.
const currentOrderKey = 'current';

class OrderDraft {
  const OrderDraft({this.table, this.lines = const []});

  final RestaurantTable? table;
  final List<OrderLine> lines;

  bool get isEmpty => lines.isEmpty;
  bool get hasDrinks => lines.any((line) => line.isDrink);
  bool get hasFood => lines.any((line) => !line.isDrink);
  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);

  int quantityOf(String menuItemId) => lines
      .where((line) => line.menuItemId == menuItemId)
      .fold(0, (sum, line) => sum + line.quantity);

  String noteOf(String menuItemId) =>
      lines.where((line) => line.menuItemId == menuItemId).firstOrNull?.description ?? '';
}

final orderDraftProvider = NotifierProvider.autoDispose.family<OrderDraftNotifier, OrderDraft, String>(
  OrderDraftNotifier.new,
);

class OrderDraftNotifier extends Notifier<OrderDraft> {
  OrderDraftNotifier(this.key);

  final String key;

  @override
  OrderDraft build() {
    // The order being taken survives leaving its screens; edit drafts go away with their screen.
    if (key == currentOrderKey) ref.keepAlive();
    return const OrderDraft();
  }

  void _setLines(List<OrderLine> lines) => state = OrderDraft(table: state.table, lines: lines);

  void load({RestaurantTable? table, required List<OrderLine> lines}) {
    state = OrderDraft(table: table, lines: lines);
  }

  void setTable(RestaurantTable? table) => state = OrderDraft(table: table, lines: state.lines);

  // Used by the menu: + adds to the item's first line, - takes from its last one.
  void changeItemQuantity(MenuItem item, int delta) {
    final lines = [...state.lines];
    final index = delta > 0
        ? lines.indexWhere((line) => line.menuItemId == item.id)
        : lines.lastIndexWhere((line) => line.menuItemId == item.id);

    if (index == -1) {
      if (delta <= 0) return;
      lines.add(OrderLine(menuItemId: item.id, name: item.name, isDrink: item.isDrink, quantity: delta));
      _setLines(lines);
      return;
    }
    _setLines(_withQuantity(lines, index, lines[index].quantity + delta));
  }

  // Notes from the menu go on the item's first line, adding the item if it isn't ordered yet.
  void setItemNote(MenuItem item, String note) {
    final index = state.lines.indexWhere((line) => line.menuItemId == item.id);
    if (index == -1) {
      _setLines([
        ...state.lines,
        OrderLine(menuItemId: item.id, name: item.name, isDrink: item.isDrink, quantity: 1, description: note),
      ]);
      return;
    }
    setNoteAt(index, note);
  }

  void changeQuantityAt(int index, int delta) {
    _setLines(_withQuantity([...state.lines], index, state.lines[index].quantity + delta));
  }

  void setNoteAt(int index, String note) {
    final lines = [...state.lines];
    lines[index] = lines[index].copyWith(description: note);
    _setLines(lines);
  }

  // Drops the given lines once they reached the backend. When nothing is left the order is done,
  // so the table is forgotten too. Returns whether the order is now complete.
  bool removeSent(List<OrderLine> sent) {
    final remaining = state.lines.where((line) => !sent.any((s) => identical(s, line))).toList();
    state = remaining.isEmpty ? const OrderDraft() : OrderDraft(table: state.table, lines: remaining);
    return remaining.isEmpty;
  }

  void clear() => state = const OrderDraft();

  List<OrderLine> _withQuantity(List<OrderLine> lines, int index, int quantity) {
    if (quantity <= 0) {
      lines.removeAt(index);
    } else {
      lines[index] = lines[index].copyWith(quantity: quantity);
    }
    return lines;
  }
}
