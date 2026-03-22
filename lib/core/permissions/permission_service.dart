import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<bool> requestNotification() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> isLocationGranted() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  Future<bool> isNotificationGranted() async {
    return await Permission.notification.isGranted;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
