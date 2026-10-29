import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/network/dio_provider.dart';
import 'package:konofrontend/features/worker/domain/menu_item.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return DioMenuRepository(ref.watch(dioProvider));
});

final menuItemsProvider =
    FutureProvider.autoDispose.family<List<MenuItem>, MenuCategory>((ref, category) {
  return ref.watch(menuRepositoryProvider).getItems(category: category);
});

abstract class MenuRepository {
  Future<List<MenuItem>> getItems({required MenuCategory category, String? restaurantId});
}

class DioMenuRepository implements MenuRepository {
  DioMenuRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<MenuItem>> getItems({
    required MenuCategory category,
    String? restaurantId,
  }) async {
    final endpoint = switch (category) {
      MenuCategory.drinks => 'get-drink-items',
      MenuCategory.food => 'get-food-items',
    };
    final response = await _dio.get<List<dynamic>>(
      '/api/Menu/$endpoint',
      queryParameters: {'restaurantId': ?restaurantId},
    );
    return response.data!
        .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
