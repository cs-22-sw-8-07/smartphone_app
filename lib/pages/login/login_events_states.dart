
import 'package:equatable/equatable.dart';

///
/// ENUMS
///
//region Enums

enum LoginButtonEvent {
  continueWithSpotify
}

//endregion

///
/// EVENT
///
//region Event

abstract class LoginPageEvent extends Equatable {
  const LoginPageEvent();

  @override
  List<Object?> get props => [];
}

class ButtonPressed extends LoginPageEvent {
  final LoginButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

//endregion

///
/// STATE
///
//region State

class LoginPageState extends Equatable {

  const LoginPageState();

  LoginPageState copyWith() {
    return const LoginPageState();
  }

  @override
  List<Object?> get props => [];
}

//endregion