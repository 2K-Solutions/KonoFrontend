import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/core/api_config.dart';
import 'package:konofrontend/core/network/jwt_claims.dart';
import 'package:konofrontend/core/network/token_storage.dart';

final tokenRefresherProvider = Provider<TokenRefresher>((ref) {
  final refresher = TokenRefresher(ref.watch(tokenStorageProvider));
  ref.onDispose(refresher.dispose);
  return refresher;
});

final sessionChangesProvider = StreamProvider<SessionChange>((ref) {
  return ref.watch(tokenRefresherProvider).changes;
});

// Emitted when a refresh changes the user's account type or restaurant.
class SessionChange {
  const SessionChange({this.accountType, this.restaurantId});

  // Null when the refresh token was rejected and the tokens were cleared.
  final String? accountType;
  final String? restaurantId;

  bool get isSignedOut => accountType == null;
}

class TokenRefresher {
  TokenRefresher(this._tokenStorage);

  final TokenStorage _tokenStorage;
  // No auth interceptor on this client, so a refresh can never trigger another refresh.
  final _dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
  final _changes = StreamController<SessionChange>.broadcast();
  Future<bool>? _inFlight;

  Stream<SessionChange> get changes => _changes.stream;

  // Exchanges the refresh token for a new token pair; concurrent callers share one request.
  // Returns true when new tokens were saved.
  Future<bool> refresh() => _inFlight ??= _refresh().whenComplete(() => _inFlight = null);

  Future<bool> _refresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;
    final oldClaims = decodeJwtPayload(await _tokenStorage.getAccessToken());

    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        '/api/Auth/refresh',
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (error) {
      // Offline: keep the current session and let the original request fail.
      if (error.response == null) return false;
      await _tokenStorage.clearTokens();
      _changes.add(const SessionChange());
      return false;
    }

    final accessToken = response.data!['accessToken'] as String;
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: response.data!['refreshToken'] as String,
    );

    final newClaims = decodeJwtPayload(accessToken);
    if (oldClaims?['accountType'] != newClaims?['accountType'] ||
        oldClaims?['restaurantId'] != newClaims?['restaurantId']) {
      _changes.add(
        SessionChange(
          accountType: newClaims?['accountType'] as String?,
          restaurantId: newClaims?['restaurantId'] as String?,
        ),
      );
    }
    return true;
  }

  void dispose() => _changes.close();
}
