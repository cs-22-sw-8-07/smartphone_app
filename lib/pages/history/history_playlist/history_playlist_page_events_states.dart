import 'package:equatable/equatable.dart';

import '../../../services/webservices/quack/models/quack_classes.dart';

///
/// ENUMS
///
//region Enums

enum HistoryPlaylistButtonEvent { back }

//endregion

///
/// EVENT
///
//region Event

abstract class HistoryPlaylistEvent extends Equatable {
  const HistoryPlaylistEvent();

  @override
  List<Object?> get props => [];
}

class ButtonPressed extends HistoryPlaylistEvent {
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

// ignore: must_be_immutable
class HistoryPlaylistState extends Equatable {
  QuackPlaylist? playlist;

  HistoryPlaylistState({this.playlist});

  HistoryPlaylistState copyWith({QuackPlaylist? playlist}) {
    return HistoryPlaylistState(playlist: playlist ?? this.playlist);
  }

  @override
  List<Object?> get props => [playlist];
}

//endregion
