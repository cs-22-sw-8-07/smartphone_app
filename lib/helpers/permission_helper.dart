import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

class PermissionHelper {
  /// Get status for the given [permission]
  Future<permission_handler.PermissionStatus> getStatus(
      permission_handler.Permission permission) {
    return permission.status;
  }

  /// Open the app settings
  Future<bool> openAppSettings() {
    return permission_handler.openAppSettings();
  }

  /// Request permissions for all the given [permissions]
  Future<
      Map<permission_handler.Permission,
          permission_handler.PermissionStatus>> requestPermissions(
      List<permission_handler.PermissionWithService> permissions) {
    return permissions.request();
  }
}
