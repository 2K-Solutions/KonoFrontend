import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/network/api_error.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/bottom_action_bar.dart';
import 'package:konofrontend/core/widgets/square_icon_button.dart';
import 'package:konofrontend/features/worker/data/order_repository.dart';
import 'package:konofrontend/features/worker/domain/order.dart';

// The worker's open orders, one per table.
class WorkerTablesScreen extends ConsumerStatefulWidget {
  const WorkerTablesScreen({super.key});

  @override
  ConsumerState<WorkerTablesScreen> createState() => _WorkerTablesScreenState();
}

class _WorkerTablesScreenState extends ConsumerState<WorkerTablesScreen> {
  String? _busyOrderId;

  Future<void> _refresh() async {
    ref.invalidate(restaurantTablesProvider);
    ref.invalidate(myOrdersProvider);
    try {
      await ref.read(myOrdersProvider.future);
    } catch (_) {
      // The list shows the error itself.
    }
  }

  Future<void> _edit(Order order) async {
    await context.push(AppRoutes.workerEditOrderFor(order.id));
    if (mounted) ref.invalidate(myOrdersProvider);
  }

  Future<void> _delete(Order order, String tableLabel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete the order for $tableLabel?'),
        content: const Text('The order and all of its items will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final repository = ref.read(orderRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busyOrderId = order.id);
    String message;
    try {
      await repository.deleteOrder(order.id);
      message = 'The order for $tableLabel was deleted.';
    } catch (error) {
      message = apiErrorMessage(error, fallback: 'Could not delete the order. Please try again.');
    }
    if (!mounted) return;
    setState(() => _busyOrderId = null);
    ref.invalidate(myOrdersProvider);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(myOrdersProvider);
    // Only used for labels, so the list still works if the tables can't be loaded.
    final tableNumbers = <String, int>{
      for (final table in ref.watch(restaurantTablesProvider).value ?? const []) table.id: table.number,
    };

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tables', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Your open orders by table.', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 24),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: orders.when(
                    data: (data) => _buildList(data, tableNumbers),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => _ScrollableMessage(
                      apiErrorMessage(error, fallback: 'Could not load your orders. Pull down to retry.'),
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        actions: [BottomAction(icon: Icons.arrow_back, label: 'Back', onTap: () => context.pop())],
      ),
    );
  }

  Widget _buildList(List<Order> orders, Map<String, int> tableNumbers) {
    if (orders.isEmpty) return const _ScrollableMessage('You have no open orders.');

    final sorted = [...orders]
      ..sort((a, b) => (tableNumbers[a.tableId] ?? 1 << 16).compareTo(tableNumbers[b.tableId] ?? 1 << 16));

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: sorted.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = sorted[index];
        final number = tableNumbers[order.tableId];
        final label = number == null ? 'this table' : 'table $number';
        final isBusy = _busyOrderId == order.id;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          decoration: AppDecorations.card,
          child: Row(
            children: [
              const Icon(Icons.table_restaurant_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  number == null ? 'Table' : 'Table $number',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ),
              if (isBusy)
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else ...[
                SquareIconButton(
                  icon: Icons.delete_outline,
                  color: AppColors.danger,
                  tooltip: 'Delete order',
                  onPressed: _busyOrderId == null ? () => _delete(order, label) : null,
                ),
                const SizedBox(width: 8),
                SquareIconButton(
                  icon: Icons.edit_outlined,
                  filled: true,
                  tooltip: 'Edit order',
                  onPressed: _busyOrderId == null ? () => _edit(order) : null,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// RefreshIndicator needs a scrollable child, even for messages.
class _ScrollableMessage extends StatelessWidget {
  const _ScrollableMessage(this.message, {this.color = AppColors.textMuted});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Center(
            child: Text(message, style: TextStyle(color: color), textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
