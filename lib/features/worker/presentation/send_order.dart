import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/network/api_error.dart';
import 'package:konofrontend/features/worker/data/order_draft.dart';
import 'package:konofrontend/features/worker/data/order_service.dart';
import 'package:konofrontend/features/worker/domain/order.dart';
import 'package:konofrontend/features/worker/presentation/widgets/table_number_dialog.dart';

enum OrderPart { drinks, food, all }

// Sends part of the order being taken to its table, asking for the table first if needed.
// Sent lines leave the order. Returns true once nothing is left to send.
Future<bool> sendCurrentOrder(BuildContext context, WidgetRef ref, OrderPart part) async {
  final notifier = ref.read(orderDraftProvider(currentOrderKey).notifier);
  final draft = ref.read(orderDraftProvider(currentOrderKey));
  final service = ref.read(orderServiceProvider);
  final messenger = ScaffoldMessenger.of(context);
  void show(String message) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  final lines = draft.lines.where((line) => _belongsTo(line, part)).toList();
  if (lines.isEmpty) {
    show('The order is empty.');
    return false;
  }

  final table = draft.table ?? await pickTable(context, ref);
  if (table == null) return false;
  notifier.setTable(table);

  try {
    await service.sendToTable(tableId: table.id, lines: lines);
  } catch (error) {
    show(apiErrorMessage(error, fallback: 'Could not send the order. Please try again.'));
    return false;
  }

  show(switch (part) {
    OrderPart.drinks => 'Drinks sent to the bar for table ${table.number}.',
    OrderPart.food => 'Food sent to the kitchen for table ${table.number}.',
    OrderPart.all => 'Order sent for table ${table.number}.',
  });
  return notifier.removeSent(lines);
}

bool _belongsTo(OrderLine line, OrderPart part) => switch (part) {
  OrderPart.drinks => line.isDrink,
  OrderPart.food => !line.isDrink,
  OrderPart.all => true,
};
