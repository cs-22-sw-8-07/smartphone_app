import 'package:equatable/equatable.dart';

import '../../../services/webservices/quack/models/quack_classes.dart';

///
/// ENUMS
///
//region Enums

enum HistoryPlaylistButtonEvent { openWithSpotify, back }

//endregion

///
/// EVENT
///
//region Event

/// Base event class
abstract class HistoryPlaylistPageEvent extends Equatable {
  const HistoryPlaylistPageEvent();
}

/// Event for when a button is pressed
///
/// [buttonEvent] tells which button is pressed
class ButtonPressed extends HistoryPlaylistPageEvent {
  final HistoryPlaylistButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

//endregion

///
/// STATE
///
//region State

/// State for History playlist page
///
/// [playlist] defines the playlist, that has its tracks shown on the page
// ignore: must_be_immutable
class HistoryPlaylistPageState extends Equatable {
  QuackPlaylist? playlist;

  HistoryPlaylistPageState({this.playlist});

  HistoryPlaylistPageState copyWith({QuackPlaylist? playlist}) {
    return HistoryPlaylistPageState(playlist: playlist ?? this.playlist);
  }

  @override
  List<Object?> get props => [playlist];
}

//endregion
