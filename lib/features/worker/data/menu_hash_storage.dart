import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final menuHashStorageProvider = Provider<MenuHashStorage>((ref) {
  return MenuHashStorage(SharedPreferencesAsync());
});

class MenuHashStorage {
  MenuHashStorage(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _menuHashKey = 'menu_hash';

  Future<String?> getHash() => _prefs.getString(_menuHashKey);

  Future<void> saveHash(String hash) => _prefs.setString(_menuHashKey, hash);

  Future<void> clearHash() => _prefs.remove(_menuHashKey);
}
