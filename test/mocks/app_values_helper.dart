import 'package:mocktail/mocktail.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

class MockAppValuesHelper extends Mock implements AppValuesHelper {
  @override
  Future<bool> saveString(AppValuesKey appValuesKey, String? value) async {
    return true;
  }

  @override
  Future<bool> saveBool(AppValuesKey appValuesKey, bool value) async {
    return true;
  }

  @override
  Future<bool> saveInteger(AppValuesKey appValuesKey, int? value) async {
    return true;
  }

  @override
  List<QuackPlaylist> getPlaylists() {
    return [];
  }
}
