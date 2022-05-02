import 'dart:convert';

import 'package:flutter/services.dart';

class AssetHelper {
  Map<String, String> assets = {};

  Future<String> _getData(String key) async {
    return await rootBundle.loadString(key);
  }

  Future<dynamic> _toJsonData(String value) async {
    return await json.decode(value);
  }

  Future<dynamic> getAssetAsJson(String key) async {
    if (assets.containsKey(key)) {
      return _toJsonData(assets[key]!);
    } else {
      String value = await _getData(key);
      assets[key] = value;
      return _toJsonData(value);
    }
  }

  Future<String> getAssetAsString(String key) async {
    if (assets.containsKey(key)) {
      return assets[key]!;
    } else {
      String value = await _getData(key);
      assets[key] = value;
      return value;
    }
  }
}
