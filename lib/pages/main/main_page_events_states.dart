import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:smartphone_app/webservices/quack/models/quack_classes.dart';
import 'package:spotify_sdk/models/player_state.dart';

///
/// ENUMS
///
//region Enums

enum MainButtonEvent {
  startStopRecommendation,
  selectPreferenceProfile,
  seeRecommendations,
  goToSettings,
  logOff,
  resizePlaylist,
  resumePausePlayer
}

enum MainTouchEvent { goToNextTrack, goToPreviousTrack }

//endregion

///
/// EVENT
///
//region Event

abstract class MainPageEvent extends Equatable {
  const MainPageEvent();

  @override
  List<Object?> get props => [];
}

class ButtonPressed extends MainPageEvent {
  final MainButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

class TouchEvent extends MainPageEvent {
  final MainTouchEvent touchEvent;

  const TouchEvent({required this.touchEvent});

  @override
  List<Object?> get props => [touchEvent];
}

class SpotifyPlayerStateChanged extends MainPageEvent {
  final PlayerState? playerState;

  const SpotifyPlayerStateChanged({required this.playerState});

  @override
  List<Object?> get props => [playerState];
}

class PlaylistReceived extends MainPageEvent {
  final QuackPlaylist? playList;

  const PlaylistReceived({required this.playList});

  @override
  List<Object?> get props => [playList];
}

class PlayPauseTrack extends MainPageEvent {
  final QuackTrack quackTrack;

  const PlayPauseTrack({required this.quackTrack});

  @override
  List<Object?> get props => [quackTrack];
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
  bool? hasJustSkipped;

  MainPageState(
      {this.isPlaylistShown,
      this.playlist,
      this.hasJustSkipped,
      this.isRecommendationStarted,
      this.playerState});

  MainPageState copyWith(
      {bool? isPlaylistShown,
      QuackPlaylist? playlist,
      bool? hasJustSkipped,
      bool? isRecommendationStarted,
      PlayerState? playerState}) {
    return MainPageState(
        playlist: playlist ?? this.playlist,
        hasJustSkipped: hasJustSkipped ?? this.hasJustSkipped,
        isPlaylistShown: isPlaylistShown ?? this.isPlaylistShown,
        playerState: playerState ?? this.playerState,
        isRecommendationStarted:
            isRecommendationStarted ?? this.isRecommendationStarted);
  }

  @override
  List<Object?> get props => [
        isPlaylistShown,
        isRecommendationStarted,
        playlist,
        playerState,
        hasJustSkipped
      ];
}

//endregion
