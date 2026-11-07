import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/network/dio_provider.dart';
import 'package:konofrontend/features/worker/domain/menu_item.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return DioMenuRepository(ref.watch(dioProvider));
});

abstract class MenuRepository {
  Future<MenuSnapshot> getMenuWithHash();

  // Returns null when [hash] still matches the restaurant's menu, otherwise the new menu.
  Future<MenuSnapshot?> checkMenuHash(String hash);
}

class DioMenuRepository implements MenuRepository {
  DioMenuRepository(this._dio);

  final Dio _dio;

  @override
  Future<MenuSnapshot> getMenuWithHash() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/Menu/get-menu-hash');
    return MenuSnapshot.fromJson(response.data!);
  }

  @override
  Future<MenuSnapshot?> checkMenuHash(String hash) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/Menu/menu-hash/check',
      queryParameters: {'hash': hash},
    );
    final data = response.data!;
    if (data['isUpToDate'] == true) return null;
    return MenuSnapshot.fromJson(data);
  }
}
