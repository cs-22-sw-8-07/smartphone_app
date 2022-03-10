import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:smartphone_app/webservices/quack/service/quack_service.dart';

import '../interfaces/quack_functions.dart';
import '../models/quack_classes.dart';

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
  Future<QuackServiceResponse<GetPlaylistResponse>> getPlaylist(String? spotifyAccessToken, QuackLocationType qlt) async {
    return QuackServiceResponse.success(GetPlaylistResponse.fromJson(
        await getJsonData("get_playlist_response.json")));
  }

//endregion
}