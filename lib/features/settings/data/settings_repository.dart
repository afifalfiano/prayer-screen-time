import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/collections/user_settings.dart';
import '../../../core/database/isar_service.dart';

class SettingsRepository {
  static const _key = 'user_settings';

  SharedPreferences get _prefs => StorageService.instance;

  UserSettings getSettings() {
    final json = _prefs.getString(_key);
    if (json == null) return UserSettings();
    return UserSettings.decode(json);
  }

  Future<void> saveSettings(UserSettings settings) async {
    await _prefs.setString(_key, settings.encode());
  }

  Future<void> updateLocation(double lat, double lng) async {
    final settings = getSettings();
    final updated = settings.copyWith(
      latitude: lat,
      longitude: lng,
      timezone: DateTime.now().timeZoneName,
    );
    await saveSettings(updated);
  }
}
