import 'package:equatable/equatable.dart';

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

//endregion

///
/// STATE
///
//region State

// ignore: must_be_immutable
class HistoryState extends Equatable {
  const HistoryState();

  HistoryState copyWith() {
    return const HistoryState();
  }

  @override
  List<Object?> get props => [];
}

//endregion
