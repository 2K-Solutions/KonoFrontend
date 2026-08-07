import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/api_config.dart';
import 'package:konofrontend/core/network/token_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
  final tokenStorage = ref.watch(tokenStorageProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await tokenStorage.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
});
