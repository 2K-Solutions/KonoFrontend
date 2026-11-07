import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/bottom_action_bar.dart';
import 'package:konofrontend/core/widgets/icon_menu_card.dart';
import 'package:konofrontend/features/notifications/push_notifications.dart';
import 'package:konofrontend/features/worker/data/menu_sync.dart';

class WorkerHomeScreen extends ConsumerStatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  ConsumerState<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends ConsumerState<WorkerHomeScreen> {
  // Pushes aren't handled in the background, so check on resume. A worker who was kicked meanwhile
  // gets a stale-membership 401 here, which refreshes the token and leaves the floor.
  late final AppLifecycleListener _lifecycleListener;

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

  @override
  Widget build(BuildContext context) {
    // Keeps the menu sync (and its periodic hash check) running while the worker is on the floor.
    ref.watch(menuSyncProvider);
    ref.watch(pushNotificationsProvider);

    return Scaffold(
      appBar: AppBar(),
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
          BottomAction(icon: Icons.table_restaurant_outlined, label: 'Tables', onTap: () {}),
          BottomAction(icon: Icons.edit_note, label: 'Edit order', onTap: () {}),
        ],
      ),
    );
  }
}
