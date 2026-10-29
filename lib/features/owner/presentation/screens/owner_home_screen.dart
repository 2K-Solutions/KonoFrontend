import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/icon_menu_card.dart';
import 'package:konofrontend/features/auth/data/logout.dart';
import 'package:konofrontend/features/owner/data/restaurant_repository.dart';
import 'package:konofrontend/features/owner/selected_restaurant_provider.dart';

class OwnerHomeScreen extends ConsumerWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(selectedRestaurantProvider);
    final restaurantCount = ref.watch(myRestaurantsProvider).value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: restaurant != null
            ? Text(restaurant.name, style: const TextStyle(fontWeight: FontWeight.w700))
            : null,
      ),
      drawer: _OwnerDrawer(canChangeRestaurant: restaurantCount > 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You are in charge', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Manage your restaurant.', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 24),
              Expanded(
                child: IconMenuCard(
                  icon: Icons.payments_outlined,
                  label: 'Revenue',
                  borderColor: AppColors.primary,
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: IconMenuCard(
                  icon: Icons.bar_chart,
                  label: 'Statistics',
                  borderColor: AppColors.primary,
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: IconMenuCard(
                  icon: Icons.groups_outlined,
                  label: 'Staff list',
                  borderColor: AppColors.primary,
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 72),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        onPressed: () => context.push(AppRoutes.ownerInviteWorker),
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}

class _OwnerDrawer extends ConsumerWidget {
  const _OwnerDrawer({required this.canChangeRestaurant});

  final bool canChangeRestaurant;

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await logout(ref);
    if (!context.mounted) return;
    context.go(AppRoutes.roleSelection);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            if (canChangeRestaurant)
              ListTile(
                leading: const Icon(Icons.storefront_outlined, color: AppColors.primary),
                title: const Text('Change restaurant'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(AppRoutes.restaurantSelection);
                },
              ),
            const Spacer(),
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.primary),
              title: const Text('Log out'),
              onTap: () => _logout(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
