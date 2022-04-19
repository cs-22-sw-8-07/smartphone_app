import 'package:equatable/equatable.dart';

import '../../services/webservices/quack/models/quack_classes.dart';

///
/// ENUMS
///
//region Enums

enum HistoryButtonEvent { back, openPlaylist, openWithSpotify }

//endregion

///
/// EVENT
///
//region Event

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class ButtonPressed extends HistoryEvent {
  final HistoryButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

class PlaylistSelected extends HistoryEvent {
  final QuackPlaylist selectedPlaylist;

  const PlaylistSelected({required this.selectedPlaylist});

  @override
  List<Object?> get props => [selectedPlaylist];
}

//endregion

///
/// STATE
///
//region State

// ignore: must_be_immutable
class HistoryState extends Equatable {
  List<QuackPlaylist>? playlists;

  HistoryState({this.playlists});

  HistoryState copyWith({List<QuackPlaylist>? playlists}) {
    return HistoryState(playlists: playlists ?? this.playlists);
  }

  @override
  List<Object?> get props => [playlists];
}

//endregion
