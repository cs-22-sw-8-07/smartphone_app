import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:smartphone_app/services/webservices/quack/interfaces/quack_functions.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/services/webservices/quack/services/quack_service.dart';

import '../helpers/asset_helper.dart';

class MockQuackService implements IQuackFunctions {
  ///
  /// VARIABLES
  ///
  //region Variables

  AssetHelper? assetHelper;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  MockQuackService({this.assetHelper}) {
    assetHelper ??= AssetHelper();
  }

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
      return QuackServiceResponse.success(GetPlaylistResponse.fromJson(
          await assetHelper!
              .getAssetAsJson("assets/mock_data/get_playlist_response.json")));
    } else {
      return QuackServiceResponse.success(
          GetPlaylistResponse.fromJson(await assetHelper!
              .getAssetAsJson("assets/mock_data/get_playlist_response2.json")));
    }
  }

//endregion
}

class MockQuackServiceError implements IQuackFunctions {
  ///
  /// OVERRIDE METHODS
  ///
//region Override methods

  @override
  Future<QuackServiceResponse<GetPlaylistResponse>> getPlaylist(
      {required QuackLocationType qlt,
      required List<QuackPlaylist> playlists}) async {
    return QuackServiceResponse.error("");
  }

//endregion
}
