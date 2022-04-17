import 'dart:async';

import 'package:smartphone_app/services/webservices/spotify/interfaces/spotify_functions.dart';
import 'package:smartphone_app/services/webservices/spotify/models/spotify_classes.dart';
import 'package:smartphone_app/services/webservices/spotify/services/spotify_service.dart';
import 'package:spotify_sdk/models/album.dart';
import 'package:spotify_sdk/models/artist.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_options.dart';
import 'package:spotify_sdk/models/player_restrictions.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/models/track.dart';

class MockSpotifyService implements ISpotifyFunctions {
  ///
  /// VARIABLES
  ///
  //region Variables

  StreamController<ConnectionStatus> connectionStatusStreamController =
      StreamController.broadcast();
  StreamController<PlayerState> playerStateStreamController =
      StreamController.broadcast();

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  dispose() {
    try {
      connectionStatusStreamController.close();
      // ignore: empty_catches
    } on Exception {}
  }

  static PlayerState getMockPlayerState({bool isPaused = false}) {
    var album = Album("test", "http://test");
    var artist = Artist("test", "http://test");
    var track = Track(
        album,
        artist,
        [],
        100,
        ImageUri(
            "spotify:image:ab67616d00001e02dbc48db84d5cde3ba6b13c07"),
        "the test track",
        "spotify:track:1K0LoLME6kJXWbOL2E5llC",
        null,
        isEpisode: false,
        isPodcast: false);
    var playerState = PlayerState(
        track,
        0,
        0,
        PlayerOptions(RepeatMode.off, isShuffling: false),
        PlayerRestrictions(
            canSkipNext: true,
            canRepeatContext: true,
            canRepeatTrack: true,
            canSeek: true,
            canSkipPrevious: true,
            canToggleShuffle: true),
        isPaused: isPaused);
    return playerState;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Future<SpotifySdkResponseWithResult<bool>> connectToSpotifyRemote() async {
    return SpotifySdkResponseWithResult.success(true);
  }

  @override
  Future<SpotifySdkResponseWithResult<bool>> disconnect() async {
    return SpotifySdkResponseWithResult.success(true);
  }

  @override
  Future<SpotifySdkResponseWithResult<String>> getAuthenticationToken() async {
    return SpotifySdkResponseWithResult.success("1234");
  }

  @override
  Future<SpotifyServiceResponse<GetCurrentUsersProfileResponse>>
      getCurrentUsersProfile({required String token}) async {
    var response = GetCurrentUsersProfileResponse(
        id: "test",
        email: "test@test.com",
        displayName: "John Doe",
        images: [SpotifyImage(url: "https://test.com")]);
    return SpotifyServiceResponse.success(response);
  }

  @override
  Future<SpotifySdkResponseWithResult<PlayerState>> getPlayerState() async {
    return SpotifySdkResponseWithResult.success(getMockPlayerState());
  }

  @override
  Future<SpotifySdkResponseWithResult<bool>> isSpotifyAppActive() async {
    return SpotifySdkResponseWithResult.success(true);
  }

  @override
  Future<SpotifySdkResponse> pause() async {
    return SpotifySdkResponse.success();
  }

  @override
  Future<SpotifySdkResponse> play({required String spotifyUri}) async {
    return SpotifySdkResponse.success();
  }

  @override
  Future<SpotifySdkResponse> playTrack(String trackId) async {
    return SpotifySdkResponse.success();
  }

  @override
  Future<SpotifySdkResponse> queue({required String spotifyUri}) async {
    return SpotifySdkResponse.success();
  }

  @override
  Future<SpotifySdkResponse> queueTrack(String trackId) async {
    return SpotifySdkResponse.success();
  }

  @override
  Future<SpotifySdkResponse> resume() async {
    return SpotifySdkResponse.success();
  }

  @override
  Future<SpotifySdkResponse> skipNext() async {
    return SpotifySdkResponse.success();
  }

  @override
  Future<SpotifySdkResponse> skipPrevious() async {
    return SpotifySdkResponse.success();
  }

  @override
  SpotifySdkResponseWithResult<Stream<ConnectionStatus>>
      subscribeConnectionStatus() {
    return SpotifySdkResponseWithResult.success(
        connectionStatusStreamController.stream);
  }

  @override
  SpotifySdkResponseWithResult<Stream<PlayerState>> subscribePlayerState() {
    return SpotifySdkResponseWithResult.success(
        playerStateStreamController.stream);
  }

//endregion

}
