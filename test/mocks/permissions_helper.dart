import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/helpers/permission_helper.dart';

class MockGrantedPermissionHelper extends Mock implements PermissionHelper {
  @override
  Future<PermissionStatus> getStatus(Permission permission) async {
    return PermissionStatus.granted;
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<PermissionWithService> permissions) async {
    return {Permission.unknown: PermissionStatus.granted};
  }

  @override
  Future<bool> openAppSettings() async {
    return true;
  }
}

class MockDeniedPermissionHelper extends Mock implements PermissionHelper {
  @override
  Future<PermissionStatus> getStatus(Permission permission) async {
    return PermissionStatus.denied;
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<PermissionWithService> permissions) async {
    return {Permission.unknown: PermissionStatus.denied};
  }

  @override
  Future<bool> openAppSettings() async {
    return true;
  }
}
