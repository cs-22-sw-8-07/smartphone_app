import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:smartphone_app/services/webservices/quack/interfaces/quack_functions.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/services/webservices/quack/services/quack_service.dart';

class MockQuackService implements IQuackFunctions {
  ///
  /// VARIABLES
  ///
  //region Variables

  dynamic jsonData1;
  dynamic jsonData2;

  //endregion

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
      {required QuackLocationType qlt,
      required List<QuackPlaylist> playlists}) async {
    if (qlt == QuackLocationType.beach) {
      jsonData1 ??= await getJsonData("get_playlist_response.json");

      return QuackServiceResponse.success(
          GetPlaylistResponse.fromJson(jsonData1));
    } else {
      jsonData2 ??= await getJsonData("get_playlist_response2.json");

      return QuackServiceResponse.success(
          GetPlaylistResponse.fromJson(jsonData2));
    }
  }

//endregion
}
