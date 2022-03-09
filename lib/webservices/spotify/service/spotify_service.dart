import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smartphone_app/webservices/spotify/interfaces/spotify_functions.dart';
import 'package:smartphone_app/webservices/spotify/models/spotify_classes.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

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
}

class SpotifySdkResponseWithResult<ResultType> {
  String? exception;
  ResultType? resultType;

  SpotifySdkResponseWithResult.error(this.exception);

  SpotifySdkResponseWithResult.success(this.resultType);

  bool get isSuccess {
    return exception == null;
  }

  String? get errorMessage {
    if (exception != null) return exception;
    return null;
  }
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
          scope:
          'app-remote-control,'
              'user-read-playback-state,'
              'user-modify-playback-state,'
              'user-read-currently-playing,'
              'user-read-private,'
              'playlist-read-collaborative,'
              'playlist-read-private'
      );
      return SpotifySdkResponseWithResult.success(authenticationToken);
    } on Exception catch (e) {
      return SpotifySdkResponseWithResult.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponseWithResult<bool>> disconnect() async {
    try {
      return SpotifySdkResponseWithResult.success(await SpotifySdk.disconnect());
    } on Exception catch (e) {
      return SpotifySdkResponseWithResult.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponseWithResult<PlayerState>> getPlayerState() async {
    try {
      PlayerState? playerState = await SpotifySdk.getPlayerState();
      return SpotifySdkResponseWithResult.success(playerState);
    } on Exception catch (e) {
      return SpotifySdkResponseWithResult.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponseWithResult<bool>> isSpotifyAppActive() async {
    try {
      return SpotifySdkResponseWithResult.success(await SpotifySdk.isSpotifyAppActive);
    } on Exception catch (e) {
      return SpotifySdkResponseWithResult.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponse> play({required String spotifyUri}) async {
    try {
      await SpotifySdk.play(spotifyUri: spotifyUri);
      return SpotifySdkResponse.success();
    } on Exception catch (e) {
      return SpotifySdkResponse.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponse> queue({required String spotifyUri}) async {
    try {
      await SpotifySdk.queue(spotifyUri: spotifyUri);
      return SpotifySdkResponse.success();
    } on Exception catch (e) {
      return SpotifySdkResponse.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponse> resume() async {
    try {
      await SpotifySdk.resume();
      return SpotifySdkResponse.success();
    } on Exception catch (e) {
      return SpotifySdkResponse.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponse> pause() async {
    try {
      await SpotifySdk.pause();
      return SpotifySdkResponse.success();
    } on Exception catch (e) {
      return SpotifySdkResponse.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponse> skipNext() async {
    try {
      await SpotifySdk.skipNext();
      return SpotifySdkResponse.success();
    } on Exception catch (e) {
      return SpotifySdkResponse.error(e.toString());
    }
  }

  @override
  Future<SpotifySdkResponse> skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious();
      return SpotifySdkResponse.success();
    } on Exception catch (e) {
      return SpotifySdkResponse.error(e.toString());
    }
  }

  @override
  SpotifySdkResponseWithResult<Stream<PlayerState>> subscribePlayerState() {
    try {
      return SpotifySdkResponseWithResult.success(SpotifySdk.subscribePlayerState());
    } on Exception catch (e) {
      return SpotifySdkResponseWithResult.error(e.toString());
    }
  }

//endregion


//endregion

}
