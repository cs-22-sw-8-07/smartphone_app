import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import '../../../../helpers/rest_helper.dart';
import '../interfaces/spotify_functions.dart';
import '../models/spotify_classes.dart';

class SpotifyServiceResponse<Response extends SpotifyResponse> {
  String? exception;
  Response? spotifyResponse;

  SpotifyServiceResponse.error(this.exception);

  SpotifyServiceResponse.success(this.spotifyResponse);

  bool get isSuccess {
    return exception == null;
  }

  String? get errorMessage {
    if (exception != null) return exception;
    return null;
  }
}

class SpotifySdkResponse {
  String? exception;

  SpotifySdkResponse.success();

  SpotifySdkResponse.error(this.exception);

  bool get isSuccess {
    return exception == null;
  }

  String? get errorMessage {
    if (exception != null) return exception;
    return null;
  }
}

class SpotifySdkResponseWithResult<ResultType> extends SpotifySdkResponse {
  ResultType? resultType;

  SpotifySdkResponseWithResult.error(String? exception)
      : super.error(exception);

  SpotifySdkResponseWithResult.success(this.resultType) : super.success();
}

class SpotifyService implements ISpotifyFunctions {
  ///
  /// STATIC
  ///
  //region Static

  static ISpotifyFunctions? _spotifyFunctions;
  static String? _clientId;
  static String? _redirectUrl;

  static init(ISpotifyFunctions spotifyFunctions) {
    _spotifyFunctions = spotifyFunctions;
    _clientId = dotenv.env['CLIENT_ID'].toString();
    _redirectUrl = dotenv.env['REDIRECT_URL'].toString();
  }

  static ISpotifyFunctions getInstance() {
    return _spotifyFunctions!;
  }

  //endregion

  ///
  /// CONSTANTS
  ///
  //region Constants

  static const String url = "https://api.spotify.com";

  //endregion

  ///
  /// VARIABLES
  ///
  //region Variables

  late RestHelper restHelper;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  SpotifyService() {
    restHelper = RestHelper(url: url);
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<T> callSpotifySdkFunction<T>(Future<T> Function() result) async {
    try {
      return await result();
    } on PlatformException {
      SpotifySdkResponseWithResult<bool> response =
          await connectToSpotifyRemote();
      if (!response.isSuccess) rethrow;
      return await result();
    }
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  //region Spotify SDK methods

  @override
  Future<SpotifySdkResponseWithResult<String>> getAuthenticationToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAccessToken(
          clientId: _clientId!,
          redirectUrl: _redirectUrl!,
          scope: 'app-remote-control,'
              'user-read-playback-state,'
              'user-modify-playback-state,'
              'user-read-currently-playing,'
              'user-read-private,'
              'user-read-email,'
              'playlist-read-collaborative,'
              'playlist-read-private');
      return SpotifySdkResponseWithResult.success(authenticationToken);
    } on Exception catch (e) {
      return SpotifySdkResponseWithResult.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponseWithResult<bool>> disconnect() async {
    try {
      return SpotifySdkResponseWithResult.success(
          await SpotifySdk.disconnect());
    } on Exception catch (e) {
      return SpotifySdkResponseWithResult.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponseWithResult<PlayerState>> getPlayerState() async {
    try {
      return callSpotifySdkFunction(() async {
        PlayerState? playerState = await SpotifySdk.getPlayerState();
        return SpotifySdkResponseWithResult.success(playerState);
      });
    } on Exception catch (e) {
      return SpotifySdkResponseWithResult.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponseWithResult<bool>> isSpotifyAppActive() async {
    try {
      return SpotifySdkResponseWithResult.success(
          await SpotifySdk.isSpotifyAppActive);
    } on Exception catch (e) {
      return SpotifySdkResponseWithResult.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponse> play({required String spotifyUri}) async {
    try {
      return callSpotifySdkFunction(() async {
        await SpotifySdk.play(spotifyUri: spotifyUri);
        return SpotifySdkResponse.success();
      });
    } on Exception catch (e) {
      return SpotifySdkResponse.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponse> queue({required String spotifyUri}) async {
    try {
      return callSpotifySdkFunction(() async {
        await SpotifySdk.queue(spotifyUri: spotifyUri);
        return SpotifySdkResponse.success();
      });
    } on Exception catch (e) {
      return SpotifySdkResponse.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponse> resume() async {
    try {
      return callSpotifySdkFunction(() async {
        await SpotifySdk.resume();
        return SpotifySdkResponse.success();
      });
    } on Exception catch (e) {
      return SpotifySdkResponse.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponse> pause() async {
    try {
      return callSpotifySdkFunction(() async {
        await SpotifySdk.pause();
        return SpotifySdkResponse.success();
      });
    } on Exception catch (e) {
      return SpotifySdkResponse.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponse> skipNext() async {
    try {
      return callSpotifySdkFunction(() async {
        await SpotifySdk.skipNext();
        return SpotifySdkResponse.success();
      });
    } on Exception catch (e) {
      return SpotifySdkResponse.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponse> skipPrevious() async {
    try {
      return callSpotifySdkFunction(() async {
        await SpotifySdk.skipPrevious();
        return SpotifySdkResponse.success();
      });
    } on Exception catch (e) {
      return SpotifySdkResponse.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponse> playTrack(String trackId) async {
    try {
      return callSpotifySdkFunction(() async {
        await SpotifySdk.play(spotifyUri: "spotify:track:" + trackId);
        return SpotifySdkResponse.success();
      });
    } on Exception catch (e) {
      return SpotifySdkResponse.error(e.toString());
    }
  }

  @override
  SpotifySdkResponseWithResult<Stream<PlayerState>> subscribePlayerState() {
    try {
      return SpotifySdkResponseWithResult.success(
          SpotifySdk.subscribePlayerState());
    } on Exception catch (e) {
      return SpotifySdkResponseWithResult.error(e.toString());
    }
  }

  @override
  SpotifySdkResponseWithResult<Stream<ConnectionStatus>>
      subscribeConnectionStatus() {
    try {
      return SpotifySdkResponseWithResult.success(
          SpotifySdk.subscribeConnectionStatus());
    } on Exception catch (e) {
      return SpotifySdkResponseWithResult.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponseWithResult<bool>> connectToSpotifyRemote() async {
    try {
      return SpotifySdkResponseWithResult.success(
          await SpotifySdk.connectToSpotifyRemote(
              clientId: _clientId!, redirectUrl: _redirectUrl!));
    } on Exception catch (e) {
      return SpotifySdkResponseWithResult.error(e.toString());
    }
  }

//endregion

  //region Spotify Web API

  @override
  Future<SpotifyServiceResponse<GetCurrentUsersProfileResponse>>
      getCurrentUsersProfile({required String token}) async {
    try {
      // Send GET request
      RestResponse restResponse = await restHelper.sendGetRequest("/v1/me",
          headers: {"Authorization": "Bearer " + token});
      // Check for errors
      if (!restResponse.isSuccess) {
        return SpotifyServiceResponse.error(restResponse.errorMessage);
      }
      // Decode json
      GetCurrentUsersProfileResponse response =
          GetCurrentUsersProfileResponse.fromJson(restResponse.jsonResponse);
      // Return success response
      return SpotifyServiceResponse.success(response);
    } on Exception catch (e) {
      return SpotifyServiceResponse.error(e.toString());
    }
  }

//endregion

//endregion

}
