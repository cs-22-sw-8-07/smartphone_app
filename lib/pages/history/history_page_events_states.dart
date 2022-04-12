import 'package:equatable/equatable.dart';

import '../../utilities/general_util.dart';

///
/// ENUMS
///
//region Enums

enum HistoryButtonEvent { back, selectedPlaylist, openInSpotify }

//endregion

///
/// EVENT
///
//region Event

abstract class HistoryPageEvent extends Equatable {
  const HistoryPageEvent();

  @override
  List<Object?> get props => [];
}

class ButtonPressed extends HistoryPageEvent {
  final HistoryButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

class Resumed extends HistoryPageEvent {
  const Resumed();
}

  // TODO: Remnant from login-page, probably should be removed
// class PermissionStateChanged extends HistoryPageEvent {
//   final PermissionState permissionState;

//   const PermissionStateChanged({required this.permissionState});

//   @override
//   List<Object> get props => [permissionState];
// }

//endregion

///
/// STATE
///
//region State

// ignore: must_be_immutable
class HistoryPageState extends Equatable {
  PermissionState? permissionState;

  HistoryPageState({this.permissionState});

  HistoryPageState copyWith({PermissionState? permissionState}) {
    return HistoryPageState(
        permissionState: permissionState ?? this.permissionState);
  }

  @override
  List<Object?> get props => [permissionState];
}

//endregion
