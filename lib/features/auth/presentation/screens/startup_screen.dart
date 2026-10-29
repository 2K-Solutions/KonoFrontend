import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/network/token_storage.dart';
import 'package:konofrontend/core/routes.dart';
import 'package:konofrontend/features/auth/data/auth_repository.dart';

class StartupScreen extends ConsumerStatefulWidget {
  const StartupScreen({super.key});

  @override
  ConsumerState<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends ConsumerState<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final route = await _resolveStartRoute();
    if (!mounted) return;
    context.go(route);
  }

  Future<String> _resolveStartRoute() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null) return AppRoutes.roleSelection;

    try {
      final result = await ref.read(authRepositoryProvider).refresh(refreshToken);
      if (!result.success) {
        await tokenStorage.clearTokens();
        return AppRoutes.roleSelection;
      }

      await tokenStorage.saveTokens(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken!,
      );

      return AppRoutes.homeFor(result.accountType);
    } on DioException {
      return AppRoutes.roleSelection;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
