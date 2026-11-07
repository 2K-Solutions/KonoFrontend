import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/features/worker/data/menu_database.dart';
import 'package:konofrontend/features/worker/data/menu_hash_storage.dart';
import 'package:konofrontend/features/worker/data/menu_repository.dart';
import 'package:konofrontend/features/worker/domain/menu_item.dart';

// Keeps the local menu in sync with the backend while something is watching it.
// State is the hash of the menu currently stored in the local database.
final menuSyncProvider = AsyncNotifierProvider.autoDispose<MenuSyncNotifier, String?>(
  MenuSyncNotifier.new,
);

final menuItemsProvider = FutureProvider.autoDispose
    .family<List<MenuItem>, ({MenuCategory category, String query})>((ref, filter) async {
      await ref.watch(menuSyncProvider.future);
      return ref.watch(menuDatabaseProvider).search(category: filter.category, query: filter.query);
    });

enum MenuCheckResult { upToDate, updated, failed }

class MenuSyncNotifier extends AsyncNotifier<String?> {
  static const checkInterval = Duration(minutes: 5);

  @override
  Future<String?> build() async {
    final timer = Timer.periodic(checkInterval, (_) => checkForUpdates());
    ref.onDispose(timer.cancel);

    final storedHash = await ref.read(menuHashStorageProvider).getHash();
    try {
      return await _sync(storedHash);
    } on DioException {
      // Offline with a cached menu: keep using it and retry on the next tick.
      if (storedHash == null) rethrow;
      return storedHash;
    }
  }

  Future<MenuCheckResult> checkForUpdates() async {
    final currentHash = state.value;
    try {
      final hash = await _sync(currentHash);
      if (hash == currentHash) return MenuCheckResult.upToDate;
      if (ref.mounted) state = AsyncData(hash);
      return MenuCheckResult.updated;
    } on DioException {
      // Try again on the next tick.
      return MenuCheckResult.failed;
    }
  }

  // Without a stored hash the full menu is fetched, otherwise only a hash check is made.
  Future<String> _sync(String? storedHash) async {
    final repository = ref.read(menuRepositoryProvider);
    if (storedHash == null) return _save(await repository.getMenuWithHash());

    final snapshot = await repository.checkMenuHash(storedHash);
    return snapshot == null ? storedHash : _save(snapshot);
  }

  Future<String> _save(MenuSnapshot snapshot) async {
    await ref.read(menuDatabaseProvider).replaceAll(snapshot.items);
    await ref.read(menuHashStorageProvider).saveHash(snapshot.menuHash);
    return snapshot.menuHash;
  }
}

// Forgets the cached menu so the next sync fetches the full menu again.
Future<void> clearLocalMenu(WidgetRef ref) async {
  await ref.read(menuHashStorageProvider).clearHash();
  await ref.read(menuDatabaseProvider).clear();
}
