import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

enum AppValuesKey { accessToken, email, displayName, userImageUrl, playlists }

class AppValuesHelper {
  ///
  /// STATIC
  ///
  //region Static

  static AppValuesHelper? _appValuesHelper;
  static SharedPreferences? _sharedPreferences;

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

  set sharedPreferences(SharedPreferences sharedPreferences) =>
      _sharedPreferences = sharedPreferences;

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  //region Helper methods

  /// Get a list from shared preferences where [T] is the type of the items
  /// contained in the list
  List<T> _getList<T>(
      AppValuesKey appValuesKey, Function(dynamic model) mapping) {
    String str = getString(appValuesKey) ?? "";
    if (str.isEmpty) return List.empty(growable: true);
    Iterable l = jsonDecode(str);
    List<T> list = List<T>.from(l.map((model) => mapping(model)));
    return list;
  }

  /// Save a list to shared preferences
  ///
  /// The String value of [appValuesKey] will be used as the key for the
  /// given [list]
  _saveList(AppValuesKey appValuesKey, List<dynamic> list) {
    var json = jsonEncode(list.map((e) => e.toJson()).toList());
    saveString(appValuesKey, json);
  }

  //endregion

  // Public methods

  /// Setup AppValuesHelper by loading shared preferences instance
  setup() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    //_sharedPreferences!.setString(AppValuesKey.playlists.toString(),
    //    await rootBundle.loadString('assets/mock_data/playlists_mock.json'));
  }

  /// Get saved playlists from shared preferences
  List<QuackPlaylist> getPlaylists() {
    return _getList<QuackPlaylist>(
        AppValuesKey.playlists, (model) => QuackPlaylist.fromJson(model));
  }

  /// Get String from shared preferences where the key is the String value of
  /// [appValuesKey]
  String? getString(AppValuesKey appValuesKey) {
    return _sharedPreferences!.getString(appValuesKey.toString());
  }

  /// Get integer from shared preferences where the key is the String value of
  /// [appValuesKey]
  int? getInteger(AppValuesKey appValuesKey) {
    try {
      return _sharedPreferences!.getInt(appValuesKey.toString());
    } catch (_) {
      return null;
    }
  }

  /// Get bool from shared preferences where the key is the String value of
  /// [appValuesKey]
  bool getBool(AppValuesKey appValuesKey) {
    try {
      return _sharedPreferences!.getBool(appValuesKey.toString()) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Override the saved playlists with the given list of [playlists]
  void savePlaylists(List<QuackPlaylist> playlists) {
    _saveList(AppValuesKey.playlists, playlists);
  }

  /// Save a single [playlist]
  ///
  /// A maximum of ten playlists will be saved
  ///
  /// If the [playlist] has the same id as the first saved playlist, it will
  /// override it.
  ///
  /// Else the [playlist] will be inserted first in the list of playlists
  void savePlaylist(QuackPlaylist playlist) {
    // Get saved playlists
    var playlists = getPlaylists();
    // Set save date for the playlist
    playlist.saveDate = DateTime.now();
    // There are already some saved playlists and
    // the first playlist has an id that matches the id of the given playlist
    if (playlists.isNotEmpty && playlists.first.id == playlist.id) {
      // Override first playlist
      playlists.first = playlist;
      // Only allow a maximum of 10 saved playlists
      while (playlists.length > 10) {
        playlists.removeLast();
      }
    } else {
      // Only allow a maximum of 10 saved playlists, is set to 9 in order to
      // make room for the new playlist
      while (playlists.length > 9) {
        playlists.removeLast();
      }
      // Insert the new playlist as the first item
      playlists.insert(0, playlist);
    }
    // Save the playlists
    savePlaylists(playlists);
  }

  /// Save a string to shared preferences
  ///
  /// The String value of [appValuesKey] will be used as the key for the
  /// given [value]
  Future<bool> saveString(AppValuesKey appValuesKey, String? value) async {
    return _sharedPreferences!.setString(appValuesKey.toString(), value ?? "");
  }

  /// Save a bool to shared preferences
  ///
  /// The String value of [appValuesKey] will be used as the key for the
  /// given [value]
  Future<bool> saveBool(AppValuesKey appValuesKey, bool value) async {
    return _sharedPreferences!.setBool(appValuesKey.toString(), value);
  }

  /// Save an integer to shared preferences
  ///
  /// The String value of [appValuesKey] will be used as the key for the
  /// given [value]
  Future<bool> saveInteger(AppValuesKey appValuesKey, int? value) async {
    if (value == null) {
      _sharedPreferences!.remove(appValuesKey.toString());
      return true;
    } else {
      return _sharedPreferences!.setInt(appValuesKey.toString(), value);
    }
  }

//endregion

//endregion

}
