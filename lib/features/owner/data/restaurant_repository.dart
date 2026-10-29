import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/network/dio_provider.dart';
import 'package:konofrontend/features/owner/domain/invite_worker_result.dart';
import 'package:konofrontend/features/owner/domain/restaurant.dart';
import 'package:konofrontend/features/owner/domain/worker_search_result.dart';

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  return DioRestaurantRepository(ref.watch(dioProvider));
});

final myRestaurantsProvider = FutureProvider.autoDispose<List<Restaurant>>((ref) {
  return ref.watch(restaurantRepositoryProvider).getMine();
});

abstract class RestaurantRepository {
  Future<List<Restaurant>> getMine();
  Future<List<WorkerSearchResult>> searchAvailableWorkers(String query);
  Future<InviteWorkerResult> inviteWorker({required String restaurantId, required String userId});
}

class DioRestaurantRepository implements RestaurantRepository {
  DioRestaurantRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Restaurant>> getMine() async {
    final response = await _dio.get<List<dynamic>>('/api/Restaurants/mine');
    return response.data!
        .map((json) => Restaurant.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<WorkerSearchResult>> searchAvailableWorkers(String query) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/Restaurants/available-users/search',
      queryParameters: {'query': query},
    );
    return response.data!
        .map(
          (json) => WorkerSearchResult.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<InviteWorkerResult> inviteWorker({
    required String restaurantId,
    required String userId,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/Restaurants/invite',
        data: {'restaurantId': restaurantId, 'userId': userId},
      );
      return const InviteWorkerResult(success: true, message: '');
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map<String, dynamic> && data['message'] is String
          ? data['message'] as String
          : 'Something went wrong. Please try again.';
      return InviteWorkerResult(success: false, message: message);
    }
  }
}
