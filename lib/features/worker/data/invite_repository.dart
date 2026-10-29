import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/network/dio_provider.dart';
import 'package:konofrontend/features/worker/domain/invite_action_result.dart';
import 'package:konofrontend/features/worker/domain/restaurant_invite.dart';

final inviteRepositoryProvider = Provider<InviteRepository>((ref) {
  return DioInviteRepository(ref.watch(dioProvider));
});

final myInvitesProvider = FutureProvider.autoDispose<List<RestaurantInvite>>((ref) {
  return ref.watch(inviteRepositoryProvider).getMine();
});

abstract class InviteRepository {
  Future<List<RestaurantInvite>> getMine();
  Future<InviteActionResult> accept(String inviteId);
  Future<InviteActionResult> decline(String inviteId);
  Future<InviteActionResult> abandonRestaurant();
}

class DioInviteRepository implements InviteRepository {
  DioInviteRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<RestaurantInvite>> getMine() async {
    final response = await _dio.get<List<dynamic>>('/api/restaurants/invites/mine');
    return response.data!
        .map((json) => RestaurantInvite.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<InviteActionResult> accept(String inviteId) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/restaurants/invite/$inviteId/accept',
      );
      return InviteActionResult(
        success: true,
        message: '',
        accessToken: response.data!['accessToken'] as String?,
        refreshToken: response.data!['refreshToken'] as String?,
      );
    } on DioException catch (error) {
      return InviteActionResult(success: false, message: _messageFrom(error));
    }
  }

  @override
  Future<InviteActionResult> decline(String inviteId) async {
    try {
      await _dio.patch<Map<String, dynamic>>('/api/restaurants/invite/$inviteId/decline');
      return const InviteActionResult(success: true, message: '');
    } on DioException catch (error) {
      return InviteActionResult(success: false, message: _messageFrom(error));
    }
  }

  @override
  Future<InviteActionResult> abandonRestaurant() async {
    try {
      await _dio.patch<Map<String, dynamic>>('/api/restaurants/abandon-restaurant');
      return const InviteActionResult(success: true, message: '');
    } on DioException catch (error) {
      return InviteActionResult(success: false, message: _messageFrom(error));
    }
  }

  String _messageFrom(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    return 'Something went wrong. Please try again.';
  }
}
