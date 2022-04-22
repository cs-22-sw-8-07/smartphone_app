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

abstract class LoginPageEvent extends Equatable {
  const LoginPageEvent();
}

class ButtonPressed extends LoginPageEvent {
  final LoginButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

class Resumed extends LoginPageEvent {
  const Resumed();

  @override
  List<Object?> get props => [];
}

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
