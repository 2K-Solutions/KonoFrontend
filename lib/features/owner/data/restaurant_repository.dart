import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/network/dio_provider.dart';
import 'package:konofrontend/features/owner/domain/restaurant.dart';

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  return DioRestaurantRepository(ref.watch(dioProvider));
});

final myRestaurantsProvider = FutureProvider<List<Restaurant>>((ref) {
  return ref.watch(restaurantRepositoryProvider).getMine();
});

abstract class RestaurantRepository {
  Future<List<Restaurant>> getMine();
}

class DioRestaurantRepository implements RestaurantRepository {
  DioRestaurantRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Restaurant>> getMine() async {
    final response = await _dio.get<List<dynamic>>('/api/restaurants/mine');
    return response.data!.map((json) => Restaurant.fromJson(json as Map<String, dynamic>)).toList();
  }
}
