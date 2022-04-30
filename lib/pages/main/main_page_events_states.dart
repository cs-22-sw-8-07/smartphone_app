import 'package:equatable/equatable.dart';
import 'package:spotify_sdk/models/player_state.dart';

import '../../services/webservices/quack/models/quack_classes.dart';

///
/// ENUMS
///
//region Enums

enum MainButtonEvent {
  startStopRecommendation,
  seeHistory,
  goToSettings,
  logOut,
  viewPlaylist,
  resumePausePlayer,
  lockUnlockQuackLocationType,
  selectManualLocation,
  refreshPlaylist,
  appendToPlaylist,
  back
}

enum MainTouchEvent { goToNextTrack, goToPreviousTrack }

//endregion

///
/// EVENT
///
//region Event

/// Base event class
abstract class MainPageEvent extends Equatable {
  const MainPageEvent();
}

/// Event for when a button is pressed
///
/// [buttonEvent] tells which button is pressed
class ButtonPressed extends MainPageEvent {
  final MainButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

/// Event for touch gestures
///
/// [touchEvent] tells which touch gesture that has been performed
class TouchEvent extends MainPageEvent {
  final MainTouchEvent touchEvent;

  const TouchEvent({required this.touchEvent});

  @override
  List<Object?> get props => [touchEvent];
}

/// Event for when the player state changes
///
/// The [playerState] holds information about the current player state
class SpotifyPlayerStateChanged extends MainPageEvent {
  final PlayerState? playerState;

  const SpotifyPlayerStateChanged({required this.playerState});

  @override
  List<Object?> get props => [playerState];
}

/// Event for when a playlist is received
///
/// The [playList] holds information about the playlist and contains the
/// tracks to be played
class PlaylistReceived extends MainPageEvent {
  final QuackPlaylist? playList;

  const PlaylistReceived({required this.playList});

  @override
  List<Object?> get props => [playList];
}

/// Event for selecting a track in the playlist
///
/// The [quackTrack] is the track that the user wants to play/pause
class TrackSelected extends MainPageEvent {
  final QuackTrack quackTrack;

  const TrackSelected({required this.quackTrack});

  @override
  List<Object?> get props => [quackTrack];
}

/// Event for changes in several MainPage values
///
/// The [currentTrack] is the track currently being played by the Quack app.
/// [isLoading] is a boolean used to indicate on the screen that something
/// is being loaded e.g. a playlist from the Qauck API.
/// [quackLocationType] is the type received from the QuackLocationService
/// based on the position provided.
// ignore: must_be_immutable
class MainPageValueChanged extends MainPageEvent {
  final QuackTrack? currentTrack;
  final bool? isLoading;
  final QuackLocationType? quackLocationType;
  final bool? hasPerformedAction;

  const MainPageValueChanged(
      {this.currentTrack,
      this.quackLocationType,
      this.isLoading,
      this.hasPerformedAction});

  @override
  List<Object?> get props =>
      [currentTrack, isLoading, quackLocationType, hasPerformedAction];
}

/// Event for selecting a location manually
///
/// The [location] is the location that the user selected
class LocationSelected extends MainPageEvent {
  final QuackLocationType? quackLocationType;

  const LocationSelected({required this.quackLocationType});

  @override
  List<Object?> get props => [quackLocationType];
}

//endregion

///
/// STATE
///
//region State

/// The state for the MainPage
///
/// [isPlaylistShown] is used to tell whether the playlist should be shown on
/// the screen or not.
/// [playerState] is received from the Spotify SDK and tells the state of the
/// Spotify player.
/// [playlist] has the content of playlist currently being played in the
/// Quack app.
/// [hasPerformedAction] is used to identify whether it was the Quack app or
/// Spotify who has changed the current track received in the [playerState].
/// [quackLocationType] is the type received from the QuackLocationService
/// based on the position provided.
/// [lockedQuackLocationType] is set either by locking the current
/// [quackLocationType] or set manually through the [LocationSelected] event.
/// [isLoading] is a boolean used to indicate on the screen that something
/// is being loaded e.g. a playlist from the Qauck API.
/// The [currentTrack] is the track currently being played by the Quack app.
///
/// [updatedItemHashCode] is used to force a state update whenever a change is
/// made to a list e.g. the list of tracks in the [playlist].
/// It can be used by setting it to the hashcode of the list in question.
// ignore: must_be_immutable
class MainPageState extends Equatable {
  bool? isPlaylistShown;
  QuackPlayerState? playerState;
  QuackPlaylist? playlist;
  bool? hasPerformedAction;
  QuackLocationType? quackLocationType;
  QuackLocationType? lockedQuackLocationType;
  bool? isLoading;
  QuackTrack? currentTrack;
  bool? isLocationListShown;

  int? updatedItemHashCode;

  MainPageState(
      {this.isPlaylistShown,
      this.playlist,
      this.isLocationListShown,
      this.currentTrack,
      this.isLoading,
      this.updatedItemHashCode,
      this.lockedQuackLocationType,
      this.quackLocationType,
      this.hasPerformedAction,
      this.playerState});

  MainPageState copyWith(
      {bool? isPlaylistShown,
      QuackPlaylist? playlist,
      QuackTrack? currentTrack,
      bool? isLocationListShown,
      int? updatedItemHashCode,
      QuackLocationType? lockedQuackLocationType,
      QuackLocationType? quackLocationType,
      bool? hasPerformedAction,
      bool? isLoading,
      QuackPlayerState? playerState}) {
    return MainPageState(
      playlist: playlist ?? this.playlist,
      isLoading: isLoading ?? this.isLoading,
      currentTrack: currentTrack ?? this.currentTrack,
      isLocationListShown: isLocationListShown ?? this.isLocationListShown,
      lockedQuackLocationType:
          lockedQuackLocationType ?? this.lockedQuackLocationType,
      hasPerformedAction: hasPerformedAction ?? this.hasPerformedAction,
      updatedItemHashCode: updatedItemHashCode ?? this.updatedItemHashCode,
      quackLocationType: quackLocationType ?? this.quackLocationType,
      isPlaylistShown: isPlaylistShown ?? this.isPlaylistShown,
      playerState: playerState ?? this.playerState,
    );
  }

  @override
  List<Object?> get props => [
        isPlaylistShown,
        currentTrack,
        isLocationListShown,
        lockedQuackLocationType,
        isLoading,
        playlist,
        playerState,
        hasPerformedAction,
        quackLocationType,
        updatedItemHashCode
      ];
}

//endregion
