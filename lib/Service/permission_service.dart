import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request Camera + Foreground + Background Location
  static Future<bool> requestAllRequiredPermissions() async {
    // 1️⃣ Camera
    final camera = await Permission.camera.request();
    if (!camera.isGranted) return false;

    // 2️⃣ Foreground Location (While using app)
    final foregroundLocation =
    await Permission.locationWhenInUse.request();
    if (!foregroundLocation.isGranted) return false;

    // 3️⃣ Background Location (Always allow)
    final backgroundLocation =
    await Permission.locationAlways.request();
    if (!backgroundLocation.isGranted) return false;

    return true;
  }
}
