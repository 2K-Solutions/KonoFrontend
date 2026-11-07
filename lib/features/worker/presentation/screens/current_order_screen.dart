import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/bottom_action_bar.dart';
import 'package:konofrontend/features/worker/data/order_draft.dart';
import 'package:konofrontend/features/worker/presentation/send_order.dart';
import 'package:konofrontend/features/worker/presentation/widgets/order_line_list.dart';
import 'package:konofrontend/features/worker/presentation/widgets/table_badge.dart';
import 'package:konofrontend/features/worker/presentation/widgets/table_number_dialog.dart';

class CurrentOrderScreen extends ConsumerStatefulWidget {
  const CurrentOrderScreen({super.key});

  @override
  ConsumerState<CurrentOrderScreen> createState() => _CurrentOrderScreenState();
}

class _CurrentOrderScreenState extends ConsumerState<CurrentOrderScreen> {
  bool _isBusy = false;

  OrderDraftNotifier get _notifier => ref.read(orderDraftProvider(currentOrderKey).notifier);

  Future<void> _chooseTable() async {
    final current = ref.read(orderDraftProvider(currentOrderKey)).table;
    final notifier = _notifier;
    setState(() => _isBusy = true);
    final table = await pickTable(context, ref, initialNumber: current?.number);
    if (table != null) notifier.setTable(table);
    if (mounted) setState(() => _isBusy = false);
  }

  Future<void> _send(OrderPart part) async {
    // The bottom bar sits outside the AbsorbPointer, so guard against double taps here.
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final completed = await sendCurrentOrder(context, ref, part);
    if (!mounted) return;
    setState(() => _isBusy = false);
    if (completed) context.go(AppRoutes.workerHome);
  }

  Future<void> _discard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard order?'),
        content: const Text('All items that haven\'t been sent yet will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Keep')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed == true) _notifier.clear();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(orderDraftProvider(currentOrderKey));

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!draft.isEmpty)
            IconButton(
              onPressed: _isBusy ? null : _discard,
              tooltip: 'Discard order',
              color: Colors.white,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
        bottom: _isBusy
            ? const PreferredSize(preferredSize: Size.fromHeight(4), child: LinearProgressIndicator())
            : null,
      ),
      body: AbsorbPointer(
        absorbing: _isBusy,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current order', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 4),
                          Text(
                            'Send drinks to the bar and food to the kitchen.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    TableBadge(number: draft.table?.number, onTap: _chooseTable),
                  ],
                ),
                const SizedBox(height: 24),
                const Expanded(
                  child: OrderLineList(
                    draftKey: currentOrderKey,
                    emptyMessage: 'Nothing left to send.\nTap + to add drinks or food.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        actions: [
          BottomAction(icon: Icons.arrow_back, label: 'Back', onTap: () => context.pop()),
          BottomAction(icon: Icons.add, label: 'Add', onTap: () => context.go(AppRoutes.workerHome)),
          if (draft.hasDrinks)
            BottomAction(
              icon: Icons.local_bar_outlined,
              label: 'Send to bar',
              color: AppColors.success,
              onTap: () => _send(OrderPart.drinks),
            ),
          if (draft.hasFood)
            BottomAction(
              icon: Icons.soup_kitchen_outlined,
              label: 'Send to kitchen',
              color: AppColors.success,
              onTap: () => _send(OrderPart.food),
            ),
        ],
      ),
    );
  }
}
