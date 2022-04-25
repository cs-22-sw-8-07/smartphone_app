import 'dart:convert';

import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/services/quack_location_service/service/quack_location_service.dart';

import '../../../../helpers/rest_helper.dart';
import '../interfaces/quack_functions.dart';
import '../models/quack_classes.dart';

class QuackServiceResponse<Response extends QuackResponse> {
  String? exception;
  Response? quackResponse;

  QuackServiceResponse.error(this.exception) {
    quackResponse = null;
  }

  QuackServiceResponse.success(this.quackResponse) {
    exception = null;
  }

  bool get isSuccess {
    if (exception != null) return false;
    return quackResponse!.isSuccessful;
  }

  Future<String?> get errorMessage async {
    if (exception != null) return exception;
    if (quackResponse != null) return quackResponse!.getErrorMessage();
    return null;
  }
}

List<int> getCurrentOffsets(
    {required List<QuackPlaylist> playlists,
    required QuackLocationType quackLocationType}) {
  List<int> currentOffsets = [];

  // Only take the offsets from playlists with a matching QuackLocationType
  for (var playlist in playlists) {
    if (playlist.quackLocationType == quackLocationType) {
      currentOffsets.addAll(playlist.allOffsets!);
    }
  }
  // Sort the list
  currentOffsets.sort((a, b) => a.compareTo(b));
  return currentOffsets;
}

class QuackService implements IQuackFunctions {
  ///
  /// STATIC
  ///
  //region Static

  static IQuackFunctions? _quackFunctions;

  static init(IQuackFunctions quackFunctions) {
    _quackFunctions = quackFunctions;
  }

  static IQuackFunctions getInstance() {
    return _quackFunctions!;
  }

  static const String recommenderControllerPath = "/Quack/Recommender/";

//endregion

  ///
  /// VARIABLES
  ///
  //region Variables

  late String url;
  late RestHelper restHelper;

//endregion

  ///
  /// CONSTRUCTOR
  ///
//region Constructor

  QuackService({required this.url}) {
    restHelper = RestHelper(url: url);
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
    try {
      List<int> currentOffsets =
          getCurrentOffsets(playlists: playlists, quackLocationType: qlt);
      String accessToken =
          AppValuesHelper.getInstance().getString(AppValuesKey.accessToken)!;

      // Send GET request
      RestResponse restResponse = await restHelper.sendPostRequest(
          recommenderControllerPath + "GetPlaylist",
          body: json.encode(currentOffsets),
          parameters: {
            "accessToken": accessToken,
            "location": getQuackLocationTypeInt(qlt).toString()
          });
      // Check for errors
      if (!restResponse.isSuccess) {
        return QuackServiceResponse.error(restResponse.errorMessage);
      }
      // Decode json
      GetPlaylistResponse response =
          GetPlaylistResponse.fromJson(restResponse.jsonResponse);
      // Return success response
      return QuackServiceResponse.success(response);
    } on Exception catch (e) {
      return QuackServiceResponse.error(e.toString());
    }
  }

//endregion
}
