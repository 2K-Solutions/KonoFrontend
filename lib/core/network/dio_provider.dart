import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/api_config.dart';
import 'package:konofrontend/core/network/token_refresher.dart';
import 'package:konofrontend/core/network/token_storage.dart';

const _membershipChangedCode = 'restaurant_membership_changed';
const _retriedKey = 'membershipRetried';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
  final tokenStorage = ref.watch(tokenStorageProvider);
  final tokenRefresher = ref.watch(tokenRefresherProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await tokenStorage.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
      // The backend rejects tokens whose restaurant membership is stale (e.g. the worker was
      // kicked). Refresh once and retry; onRequest attaches the new token to the retry.
      onError: (error, handler) async {
        final options = error.requestOptions;
        if (!_isMembershipChanged(error.response) || options.extra[_retriedKey] == true) {
          return handler.next(error);
        }
        if (!await tokenRefresher.refresh()) return handler.next(error);

        options.extra[_retriedKey] = true;
        try {
          handler.resolve(await dio.fetch<dynamic>(options));
        } on DioException catch (retryError) {
          handler.next(retryError);
        }
      },
    ),
  );

  return dio;
});

bool _isMembershipChanged(Response<dynamic>? response) {
  final data = response?.data;
  return response?.statusCode == 401 &&
      data is Map<String, dynamic> &&
      data['code'] == _membershipChangedCode;
}
