import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/network/api_error.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/bottom_action_bar.dart';
import 'package:konofrontend/core/widgets/icon_menu_card.dart';
import 'package:konofrontend/features/notifications/push_notifications.dart';
import 'package:konofrontend/features/worker/data/menu_sync.dart';
import 'package:konofrontend/features/worker/data/order_service.dart';
import 'package:konofrontend/features/worker/presentation/widgets/table_number_dialog.dart';

class WorkerHomeScreen extends ConsumerStatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  ConsumerState<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends ConsumerState<WorkerHomeScreen> {
  // Pushes aren't handled in the background, so check on resume. A worker who was kicked meanwhile
  // gets a stale-membership 401 here, which refreshes the token and leaves the floor.
  late final AppLifecycleListener _lifecycleListener;
  bool _isFindingOrder = false;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () => ref.read(menuSyncProvider.notifier).checkForUpdates(),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  // Asks for a table and opens the worker's open order for it.
  Future<void> _editOrder() async {
    if (_isFindingOrder) return;
    final service = ref.read(orderServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    void show(String message) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

    setState(() => _isFindingOrder = true);
    try {
      final table = await pickTable(context, ref);
      if (table == null) return;

      final order = await service.findOrderForTable(table.id);
      if (!mounted) return;
      if (order == null) {
        show('You have no open order for table ${table.number}.');
        return;
      }
      context.push(AppRoutes.workerEditOrderFor(order.id));
    } catch (error) {
      show(apiErrorMessage(error, fallback: 'Could not load your orders. Please try again.'));
    } finally {
      if (mounted) setState(() => _isFindingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the menu sync (and its periodic hash check) running while the worker is on the floor.
    ref.watch(menuSyncProvider);
    ref.watch(pushNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        bottom: _isFindingOrder
            ? const PreferredSize(preferredSize: Size.fromHeight(4), child: LinearProgressIndicator())
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Take an order', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Choose a category to start.', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 24),
              Expanded(
                child: IconMenuCard(
                  icon: Icons.local_bar_outlined,
                  label: 'Drinks',
                  borderColor: AppColors.primary,
                  onTap: () => context.push(AppRoutes.workerDrinks),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: IconMenuCard(
                  icon: Icons.restaurant_outlined,
                  label: 'Food',
                  borderColor: AppColors.primary,
                  onTap: () => context.push(AppRoutes.workerFood),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        actions: [
          BottomAction(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => context.push(AppRoutes.workerProfile),
          ),
          BottomAction(
            icon: Icons.table_restaurant_outlined,
            label: 'Tables',
            onTap: () => context.push(AppRoutes.workerTables),
          ),
          BottomAction(icon: Icons.edit_note, label: 'Edit order', onTap: _editOrder),
        ],
      ),
    );
  }
}
