import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

enum AppValuesKey {
  accessToken,
  email,
  displayName,
  userImageUrl,
  tracks,
  playlists
}

class AppValuesHelper {
  ///
  /// STATIC
  ///
  //region Static

  static AppValuesHelper? _appValuesHelper;
  static late SharedPreferences _sharedPreferences;

  static void init(AppValuesHelper appValuesHelper) {
    _appValuesHelper = appValuesHelper;
  }

  static AppValuesHelper getInstance() {
    _appValuesHelper ??= AppValuesHelper._();
    return _appValuesHelper!;
  }

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  AppValuesHelper._();

  //endregion

  ///
  /// PROPERTIES
  ///
  //region Properties

  List<T> _getList<T>(
      AppValuesKey appValuesKey, Function(dynamic model) mapping) {
    String str = getString(appValuesKey) ?? "";
    if (str.isEmpty) return List.empty(growable: true);
    Iterable l = jsonDecode(str);
    List<T> list = List<T>.from(l.map((model) => mapping(model)));
    return list;
  }

  _saveList(AppValuesKey appValuesKey, List<dynamic> list) {
    var json = jsonEncode(list.map((e) => e.toJson()).toList());
    saveString(appValuesKey, json);
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  setup() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    _sharedPreferences.setString(AppValuesKey.playlists.toString(),
        await rootBundle.loadString('assets/mock_data/playlists_mock.json'));
  }

  List<QuackTrack> getTracks() {
    return _getList<QuackTrack>(
        AppValuesKey.tracks, (model) => QuackTrack.fromJson(model));
  }

  List<QuackPlaylist> getPlaylists() {
    return _getList<QuackPlaylist>(
        AppValuesKey.playlists, (model) => QuackPlaylist.fromJson(model));
  }

  String? getString(AppValuesKey appValuesKey) {
    return _sharedPreferences.getString(appValuesKey.toString());
  }

  int? getInteger(AppValuesKey appValuesKey) {
    try {
      return _sharedPreferences.getInt(appValuesKey.toString());
    } on Exception catch (_) {
      return null;
    }
  }

  bool getBool(AppValuesKey appValuesKey) {
    try {
      return _sharedPreferences.getBool(appValuesKey.toString()) ?? false;
    } on Exception catch (_) {
      return false;
    }
  }

  savePlaylists(List<QuackPlaylist> playlists) {
    _saveList(AppValuesKey.playlists, playlists);
  }

  Future<bool> saveString(AppValuesKey appValuesKey, String? value) async {
    return _sharedPreferences.setString(appValuesKey.toString(), value ?? "");
  }

  Future<bool> saveBool(AppValuesKey appValuesKey, bool value) async {
    return _sharedPreferences.setBool(appValuesKey.toString(), value);
  }

  Future<bool> saveInteger(AppValuesKey appValuesKey, int? value) async {
    if (value == null) {
      _sharedPreferences.remove(appValuesKey.toString());
      return true;
    } else {
      return _sharedPreferences.setInt(appValuesKey.toString(), value);
    }
  }

//endregion

}
