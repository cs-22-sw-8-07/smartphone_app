import 'package:equatable/equatable.dart';

import '../../utilities/general_util.dart';

///
/// ENUMS
///
//region Enums

enum LoginButtonEvent {
  continueWithSpotify,
  goToSettings
}

//endregion

///
/// EVENT
///
//region Event

/// Base event class
abstract class LoginPageEvent extends Equatable {
  const LoginPageEvent();
}

/// Event for when a button is pressed
///
/// [buttonEvent] tells which button is pressed
class ButtonPressed extends LoginPageEvent {
  final LoginButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

/// Event for when the page is resumed
class Resumed extends LoginPageEvent {
  const Resumed();

  @override
  List<Object?> get props => [];
}

/// Event for when the [permissionState] changes
class PermissionStateChanged extends LoginPageEvent {
  final PermissionState permissionState;

  const PermissionStateChanged({required this.permissionState});

  @override
  List<Object> get props => [permissionState];
}

//endregion

///
/// STATE
///
//region State

/// The state for the Login page
///
/// [permissionState] is used to tell whether the app have gotten all
/// permissions e.g. permission to location
// ignore: must_be_immutable
class LoginPageState extends Equatable {
  PermissionState? permissionState;

  LoginPageState({this.permissionState});

  LoginPageState copyWith({PermissionState? permissionState}) {
    return LoginPageState(permissionState: permissionState ?? this.permissionState);
  }

  @override
  List<Object?> get props => [permissionState];
}

//endregion
