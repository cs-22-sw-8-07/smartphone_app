

import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/player_state.dart';

import '../models/spotify_classes.dart';
import '../services/spotify_service.dart';

class ISpotifyFunctions {

  //region Spotify SDK methods

  Future<SpotifySdkResponse> playTrack(String trackId) async {
    throw UnimplementedError();
  }

  Future<SpotifySdkResponse> queueTrack(String trackId) async {
    throw UnimplementedError();
  }

  Future<SpotifySdkResponseWithResult<String>> getAuthenticationToken() async {
    throw UnimplementedError();
  }

  Future<SpotifySdkResponseWithResult<bool>> isSpotifyAppActive() async {
    throw UnimplementedError();
  }

  Future<SpotifySdkResponseWithResult<bool>> connectToSpotifyRemote() async {
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

  SpotifySdkResponseWithResult<Stream<ConnectionStatus>> subscribeConnectionStatus() {
    throw UnimplementedError();
  }

  //endregion

  //region Spotify Web API

  Future<SpotifyServiceResponse<GetCurrentUsersProfileResponse>>
  getCurrentUsersProfile({required String token}) {
    throw UnimplementedError();
  }

  //endregion

}