

import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/player_state.dart';

import '../models/spotify_classes.dart';
import '../services/spotify_service.dart';

class ISpotifyFunctions {

  //region Spotify SDK methods

  /// Play track with a given [trackId]
  Future<SpotifySdkResponse> playTrack(String trackId) async {
    throw UnimplementedError();
  }

  /// Queue a track with a given [trackId]
  Future<SpotifySdkResponse> queueTrack(String trackId) async {
    throw UnimplementedError();
  }

  /// Get authentication token
  Future<SpotifySdkResponseWithResult<String>> getAuthenticationToken() async {
    throw UnimplementedError();
  }

  /// Check if the Spotify app is installed on the device
  Future<SpotifySdkResponseWithResult<bool>> isSpotifyAppActive() async {
    throw UnimplementedError();
  }

  /// Connect to the Spotify remote, has to be called
  /// before using these methods:
  ///
  /// [playTrack]
  /// [queueTrack]
  /// [getPlayerState]
  /// [queue]
  /// [play]
  /// [pause]
  /// [resume]
  /// [skipNext]
  /// [skipPrevious]
  /// [subscribePlayerState]
  Future<SpotifySdkResponseWithResult<bool>> connectToSpotifyRemote() async {
    throw UnimplementedError();
  }

  /// Disconnect from the Spotify remote
  Future<SpotifySdkResponseWithResult<bool>> disconnect() async {
    throw UnimplementedError();
  }

  /// Get the player state from the Spotify remote
  Future<SpotifySdkResponseWithResult<PlayerState>> getPlayerState() {
    throw UnimplementedError();
  }

  /// Queue using a [spotifyUri] e.g. spotify:track:2GNEJcmdJuQK97mWea637Y
  Future<SpotifySdkResponse> queue({required String spotifyUri}) async {
    throw UnimplementedError();
  }

  /// Play using a [spotifyUri] e.g. spotify:track:2GNEJcmdJuQK97mWea637Y
  Future<SpotifySdkResponse> play({required String spotifyUri}) async {
    throw UnimplementedError();
  }

  /// Pause the Spotify player
  Future<SpotifySdkResponse> pause() async {
    throw UnimplementedError();
  }

  /// Resume the Spotify player
  Future<SpotifySdkResponse> resume() async {
    throw UnimplementedError();
  }

  /// Skip in the Spotify player
  Future<SpotifySdkResponse> skipNext() async {
    throw UnimplementedError();
  }

  /// Go to previous in the Spotify player
  Future<SpotifySdkResponse> skipPrevious() async {
    throw UnimplementedError();
  }

  /// Subscribe to the Spotify player state, has to be called every time you
  /// connect to the Spotify remote using [connectToSpotifyRemote]
  SpotifySdkResponseWithResult<Stream<PlayerState>> subscribePlayerState() {
    throw UnimplementedError();
  }

  /// Subscribe to the connection status for the Spotify remote
  SpotifySdkResponseWithResult<Stream<ConnectionStatus>> subscribeConnectionStatus() {
    throw UnimplementedError();
  }

  //endregion

  //region Spotify Web API

  /// Get data from a user's Spotify profile using a [token]
  Future<SpotifyServiceResponse<GetCurrentUsersProfileResponse>>
  getCurrentUsersProfile({required String token}) {
    throw UnimplementedError();
  }

  //endregion

}