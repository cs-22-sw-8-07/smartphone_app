import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:smartphone_app/services/webservices/quack/interfaces/quack_functions.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/services/webservices/quack/services/quack_service.dart';

class MockQuackService implements IQuackFunctions {
  ///
  /// METHODS
  ///
  //region Methods

  Future<dynamic> getJsonData(String assetName) async {
    String jsonStr =
        await rootBundle.loadString('assets/mock_data/' + assetName);
    return await json.decode(jsonStr);
  }

//endregion

  ///
  /// OVERRIDE METHODS
  ///
//region Override methods

  @override
  Future<QuackServiceResponse<GetPlaylistResponse>> getPlaylist(
      QuackLocationType qlt) async {
    if (qlt == QuackLocationType.beach) {
      return QuackServiceResponse.success(GetPlaylistResponse.fromJson(
          await getJsonData("get_playlist_response.json")));
    } else {
      return QuackServiceResponse.success(GetPlaylistResponse.fromJson(
          await getJsonData("get_playlist_response2.json")));
    }
  }

//endregion
}
