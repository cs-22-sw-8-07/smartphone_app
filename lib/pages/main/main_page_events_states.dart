import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

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
  resizePlaylist
}

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

//endregion

///
/// STATE
///
//region State

// ignore: must_be_immutable
class MainPageState extends Equatable {
  bool? isPlaylistShown;
  bool? isRecommendationStarted;

  MainPageState({this.isPlaylistShown, this.isRecommendationStarted});

  MainPageState copyWith(
      {bool? isPlaylistShown, bool? isRecommendationStarted}) {
    return MainPageState(
        isPlaylistShown: isPlaylistShown ?? this.isPlaylistShown,
        isRecommendationStarted:
            isRecommendationStarted ?? this.isRecommendationStarted);
  }

  @override
  List<Object?> get props => [isPlaylistShown, isRecommendationStarted];
}

//endregion
