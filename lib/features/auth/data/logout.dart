import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/network/token_storage.dart';
import 'package:konofrontend/features/auth/data/auth_repository.dart';

Future<void> logout(WidgetRef ref) async {
  final tokenStorage = ref.read(tokenStorageProvider);
  final refreshToken = await tokenStorage.getRefreshToken();
  if (refreshToken != null) {
    await ref.read(authRepositoryProvider).logout(refreshToken);
  }
  await tokenStorage.clearTokens();
}
