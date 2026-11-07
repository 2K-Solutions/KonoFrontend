import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/network/dio_provider.dart';

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DioDeviceRepository(ref.watch(dioProvider));
});

// Failures are ignored: the device is registered again on the next app start.
abstract class DeviceRepository {
  Future<void> register(String token);
  Future<void> remove(String token);
}

class DioDeviceRepository implements DeviceRepository {
  DioDeviceRepository(this._dio);

  final Dio _dio;

  @override
  Future<void> register(String token) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/Notifications/devices',
        data: {'token': token, 'platform': Platform.operatingSystem},
      );
    } on DioException {
      return;
    }
  }

  @override
  Future<void> remove(String token) async {
    try {
      await _dio.delete<void>('/api/Notifications/delete-device', data: {'token': token});
    } on DioException {
      return;
    }
  }
}
