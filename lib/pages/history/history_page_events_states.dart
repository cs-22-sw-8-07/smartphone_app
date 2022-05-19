import 'package:equatable/equatable.dart';

import '../../services/webservices/quack/models/quack_classes.dart';

///
/// ENUMS
///
//region Enums

enum HistoryButtonEvent { back, openWithSpotify }

//endregion

///
/// EVENT
///
//region Event

/// Base event class
abstract class HistoryPageEvent extends Equatable {
  const HistoryPageEvent();
}

/// Event for when a button is pressed
///
/// [buttonEvent] tells which button is pressed
class ButtonPressed extends HistoryPageEvent {
  final HistoryButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

/// Event for when a [playlist] is selected
class PlaylistSelected extends HistoryPageEvent {
  final QuackPlaylist playlist;

  const PlaylistSelected({required this.playlist});

  @override
  List<Object?> get props => [playlist];
}

//endregion

///
/// STATE
///
//region State

/// State for the History page
///
/// [playlists] specifies the current list of playlists shown on the page
// ignore: must_be_immutable
class HistoryPageState extends Equatable {
  List<QuackPlaylist>? playlists;

  HistoryPageState({this.playlists});

  HistoryPageState copyWith({List<QuackPlaylist>? playlists}) {
    return HistoryPageState(playlists: playlists ?? this.playlists);
  }

  @override
  List<Object?> get props => [playlists];
}

//endregion
