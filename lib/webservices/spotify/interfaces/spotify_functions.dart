

import 'package:smartphone_app/webservices/spotify/service/spotify_service.dart';
import 'package:spotify_sdk/models/player_state.dart';

class ISpotifyFunctions {

  //region Spotify SDK methods

  Future<SpotifySdkResponseWithResult<String>> getAuthenticationToken() async {
    throw UnimplementedError();
  }

  Future<SpotifySdkResponseWithResult<bool>> isSpotifyAppActive() async {
    throw UnimplementedError();
  }

  Future<SpotifySdkResponseWithResult<bool>> disconnect() async {
    throw UnimplementedError();
  }

  Future<SpotifySdkResponseWithResult<PlayerState>> getPlayerState() {
    throw UnimplementedError();
  }

  Future<SpotifySdkResponse> queue({required String spotifyUri}) async {
    throw UnimplementedError();
  }

  Future<SpotifySdkResponse> play({required String spotifyUri}) async {
    throw UnimplementedError();
  }

  Future<SpotifySdkResponse> pause() async {
    throw UnimplementedError();
  }

  Future<SpotifySdkResponse> resume() async {
    throw UnimplementedError();
  }

  Future<SpotifySdkResponse> skipNext() async {
    throw UnimplementedError();
  }

  Future<SpotifySdkResponse> skipPrevious() async {
    throw UnimplementedError();
  }

  SpotifySdkResponseWithResult<Stream<PlayerState>> subscribePlayerState() {
    throw UnimplementedError();
  }

  //endregion

  //region Spotify Web API


  //endregion

}