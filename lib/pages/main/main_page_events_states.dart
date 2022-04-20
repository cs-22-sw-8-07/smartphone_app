import 'package:equatable/equatable.dart';
import 'package:spotify_sdk/models/player_state.dart';

import '../../services/webservices/quack/models/quack_classes.dart';

///
/// ENUMS
///
//region Enums

enum MainButtonEvent {
  startStopRecommendation,
  seeRecommendations,
  goToSettings,
  logOff,
  viewPlaylist,
  resumePausePlayer,
  lockUnlockQuackLocationType,
  selectManualLocation,
  refreshPlaylist,
  appendToPlaylist
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

  @override
  List<Object?> get props => [];
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

/// Event for selecting a location manually
///
/// The [location] is the location that the user selected
class LocationSelected extends MainPageEvent {
  final QuackLocationType quackLocation;

  const LocationSelected({required this.quackLocation});

  @override
  List<Object?> get props => [quackLocation];
}

// ignore: must_be_immutable
class MainPageValueChanged extends MainPageEvent {
  final QuackTrack? currentTrack;
  final bool? isRecommendationStarted;
  final bool? isLoading;
  final QuackLocationType? quackLocationType;

  const MainPageValueChanged(
      {this.currentTrack,
      this.isRecommendationStarted,
      this.quackLocationType,
      this.isLoading});

  @override
  List<Object?> get props =>
      [currentTrack, isRecommendationStarted, isLoading, quackLocationType];
}

class HasPerformedSpotifyPlayerAction extends MainPageEvent {
  const HasPerformedSpotifyPlayerAction();
}

//endregion

///
/// STATE
///
//region State

// ignore: must_be_immutable
class MainPageState extends Equatable {
  bool? isPlaylistShown;
  bool? isLocationListShown;
  bool? isRecommendationStarted;
  PlayerState? playerState;
  QuackPlaylist? playlist;
  bool? hasJustPerformedAction;
  QuackLocationType? quackLocationType;
  QuackLocationType? lockedQuackLocationType;
  bool? isLoading;
  QuackTrack? currentTrack;

  int? updatedItemHashCode;

  MainPageState(
      {this.isPlaylistShown,
      this.isLocationListShown,
      this.playlist,
      this.currentTrack,
      this.isLoading,
      this.updatedItemHashCode,
      this.lockedQuackLocationType,
      this.quackLocationType,
      this.hasJustPerformedAction,
      this.isRecommendationStarted,
      this.playerState});

  MainPageState copyWith(
      {bool? isPlaylistShown,
      bool? isLocationListShown,
      QuackPlaylist? playlist,
      QuackTrack? currentTrack,
      int? updatedItemHashCode,
      QuackLocationType? lockedQuackLocationType,
      QuackLocationType? quackLocationType,
      bool? hasJustPerformedAction,
      bool? isLoading,
      bool? isRecommendationStarted,
      PlayerState? playerState}) {
    return MainPageState(
        playlist: playlist ?? this.playlist,
        isLoading: isLoading ?? this.isLoading,
        currentTrack: currentTrack ?? this.currentTrack,
        lockedQuackLocationType:
            lockedQuackLocationType ?? this.lockedQuackLocationType,
        hasJustPerformedAction:
            hasJustPerformedAction ?? this.hasJustPerformedAction,
        updatedItemHashCode: updatedItemHashCode ?? this.updatedItemHashCode,
        quackLocationType: quackLocationType ?? this.quackLocationType,
        isPlaylistShown: isPlaylistShown ?? this.isPlaylistShown,
        isLocationListShown: isLocationListShown ?? this.isLocationListShown,
        playerState: playerState ?? this.playerState,
        isRecommendationStarted:
            isRecommendationStarted ?? this.isRecommendationStarted);
  }

  @override
  List<Object?> get props => [
        isPlaylistShown,
        isLocationListShown,
        currentTrack,
        isRecommendationStarted,
        lockedQuackLocationType,
        isLoading,
        playlist,
        playerState,
        hasJustPerformedAction,
        quackLocationType,
        updatedItemHashCode
      ];
}

//endregion
