import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/collections/blocked_app.dart';
import '../../../core/database/isar_service.dart';

class BlockingRepository {
  static const _key = 'blocked_apps';

  SharedPreferences get _prefs => StorageService.instance;

  List<BlockedApp> getBlockedApps() {
    final json = _prefs.getString(_key);
    if (json == null) return [];
    return BlockedApp.decodeList(json);
  }

  Future<void> saveBlockedApps(List<BlockedApp> apps) async {
    await _prefs.setString(_key, BlockedApp.encodeList(apps));
  }

  Future<void> addBlockedApp(BlockedApp app) async {
    final apps = getBlockedApps();
    // Avoid duplicates
    apps.removeWhere((a) => a.packageName == app.packageName);
    apps.add(app);
    await saveBlockedApps(apps);
  }

  Future<void> removeBlockedApp(String packageName) async {
    final apps = getBlockedApps();
    apps.removeWhere((a) => a.packageName == packageName);
    await saveBlockedApps(apps);
  }

  Future<void> toggleApp(String packageName, bool isBlocked) async {
    final apps = getBlockedApps();
    for (final app in apps) {
      if (app.packageName == packageName) {
        app.isBlocked = isBlocked;
      }
    }
    await saveBlockedApps(apps);
  }

  List<String> getActiveBlockedPackages() {
    return getBlockedApps()
        .where((a) => a.isBlocked)
        .map((a) => a.packageName)
        .toList();
  }
}
