import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/features/owner/data/restaurant_repository.dart';
import 'package:konofrontend/features/owner/domain/restaurant.dart';
import 'package:konofrontend/features/owner/selected_restaurant_provider.dart';

class RestaurantSelectionScreen extends ConsumerWidget {
  const RestaurantSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurants = ref.watch(myRestaurantsProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose your restaurant', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Select which restaurant you\'d like to manage.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: restaurants.when(
                  data: (data) => _RestaurantList(restaurants: data),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text(
                      'Could not load restaurants. Please try again.',
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantList extends ConsumerWidget {
  const _RestaurantList({required this.restaurants});

  final List<Restaurant> restaurants;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (restaurants.isEmpty) {
      return Center(
        child: Text(
          'No restaurants are linked to your account yet.',
          style: TextStyle(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: restaurants.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              ref.read(selectedRestaurantProvider.notifier).select(restaurant);
              context.go(AppRoutes.ownerHome);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: AppDecorations.card,
              child: Row(
                children: [
                  const Icon(Icons.storefront_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      restaurant.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.primary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
