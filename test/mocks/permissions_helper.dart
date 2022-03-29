import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/helpers/permission_helper.dart';

class MockGrantedPermissionHelper extends Mock implements PermissionHelper {
  @override
  Future<PermissionStatus> getStatus(Permission permission) async {
    return PermissionStatus.granted;
  }
}

class MockDeniedPermissionHelper extends Mock implements PermissionHelper {
  @override
  Future<PermissionStatus> getStatus(Permission permission) async {
    return PermissionStatus.denied;
  }
}
