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
  resizePlaylist,
  resumePausePlayer,
  lockUnlockQuackLocationType,
  selectManualLocation
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

// ignore: must_be_immutable
class MainPageValueChanged extends MainPageEvent {
  QuackTrack? currentTrack;
  bool? isRecommendationStarted;
  bool? isLoading;
  QuackLocationType? quackLocationType;

  MainPageValueChanged(
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
  bool? isRecommendationStarted;
  PlayerState? playerState;
  QuackPlaylist? playlist;
  bool? hasJustPerformedAction;
  QuackLocationType? quackLocationType;
  QuackLocationType? lockedQuackLocationType;
  bool? isLoading;
  QuackTrack? currentTrack;

  MainPageState(
      {this.isPlaylistShown,
      this.playlist,
      this.currentTrack,
      this.isLoading,
      this.lockedQuackLocationType,
      this.quackLocationType,
      this.hasJustPerformedAction,
      this.isRecommendationStarted,
      this.playerState});

  MainPageState copyWith(
      {bool? isPlaylistShown,
      QuackPlaylist? playlist,
      QuackTrack? currentTrack,
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
        quackLocationType: quackLocationType ?? this.quackLocationType,
        isPlaylistShown: isPlaylistShown ?? this.isPlaylistShown,
        playerState: playerState ?? this.playerState,
        isRecommendationStarted:
            isRecommendationStarted ?? this.isRecommendationStarted);
  }

  @override
  List<Object?> get props => [
        isPlaylistShown,
        currentTrack,
        isRecommendationStarted,
        lockedQuackLocationType,
        isLoading,
        playlist,
        playerState,
        hasJustPerformedAction,
        quackLocationType
      ];
}

//endregion
