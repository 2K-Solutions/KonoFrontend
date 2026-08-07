import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/features/owner/domain/restaurant.dart';

class SelectedRestaurantNotifier extends Notifier<Restaurant?> {
  @override
  Restaurant? build() => null;

  void select(Restaurant restaurant) => state = restaurant;
}

final selectedRestaurantProvider =
    NotifierProvider<SelectedRestaurantNotifier, Restaurant?>(SelectedRestaurantNotifier.new);
