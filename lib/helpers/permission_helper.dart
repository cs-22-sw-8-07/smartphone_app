import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  /// Get status for the given [permission]
  Future<PermissionStatus> getStatus(Permission permission) {
    return permission.status;
  }

  /// Open the app settings
  Future<bool> openAppSettings() {
    return openAppSettings();
  }

  /// Request permissions for all the given [permissions]
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<PermissionWithService> permissions) {
    return permissions.request();
  }
}
