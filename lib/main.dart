import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/isar_service.dart';
import 'features/notification/data/notification_service.dart';
import 'features/notification/background/background_worker.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await StorageService.init();
  await NotificationService.init();
  await BackgroundWorker.init();
  await BackgroundWorker.registerDailyTask();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const PrayerScreenTimeApp(),
    ),
  );
}
