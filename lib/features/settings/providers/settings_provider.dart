import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/collections/user_settings.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

class SettingsNotifier extends StateNotifier<UserSettings> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo) : super(_repo.getSettings());

  Future<void> setCalculationMethod(int index) async {
    final updated = state.copyWith(calculationMethodIndex: index);
    await _repo.saveSettings(updated);
    state = updated;
  }

  Future<void> setBlockDurations({int? before, int? after}) async {
    final updated = state.copyWith(
      blockDurationBefore: before ?? state.blockDurationBefore,
      blockDurationAfter: after ?? state.blockDurationAfter,
    );
    await _repo.saveSettings(updated);
    state = updated;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final updated = state.copyWith(notificationsEnabled: enabled);
    await _repo.saveSettings(updated);
    state = updated;
  }

  Future<void> setPrayerNotification(String prayer, bool enabled) async {
    final notifications = Map<String, bool>.of(state.prayerNotifications);
    notifications[prayer] = enabled;
    final updated = state.copyWith(prayerNotifications: notifications);
    await _repo.saveSettings(updated);
    state = updated;
  }

  Future<void> updateLocation(double lat, double lng) async {
    await _repo.updateLocation(lat, lng);
    state = _repo.getSettings();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});
