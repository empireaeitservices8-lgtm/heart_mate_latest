import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Requests all core permissions required for calls and notifications.
  /// Calling this before the user reaches the Home screen ensures outgoing
  /// calls can initiate immediately without permission interruption dialogs.
  static Future<void> requestAppPermissions() async {
    try {
      await [
        Permission.microphone,
        Permission.camera,
        Permission.notification,
      ].request();
    } catch (e) {
      print('[PermissionService] Error requesting permissions: $e');
    }
  }

  /// Checks whether call-related permissions are already granted.
  static Future<bool> hasCallPermissions({bool isVideo = false}) async {
    try {
      final micStatus = await Permission.microphone.status;
      if (isVideo) {
        final camStatus = await Permission.camera.status;
        return micStatus.isGranted && camStatus.isGranted;
      }
      return micStatus.isGranted;
    } catch (e) {
      print('[PermissionService] Error checking permissions: $e');
      return false;
    }
  }
}
