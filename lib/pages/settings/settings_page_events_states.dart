
import 'package:equatable/equatable.dart';

///
/// ENUMS
///
//region Enums

enum SettingsButtonEvent { back, deleteAccount }
//endregion

///
/// EVENT
///
//region Event

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
}

class ButtonPressed extends SettingsEvent {
  final SettingsButtonEvent buttonEvent;

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
class SettingsState extends Equatable {
  const SettingsState();

  SettingsState copyWith() {
    return const SettingsState();
  }

  @override
  List<Object?> get props =>
      [0]; // 0 is used in order to enforce an equals check
}

//endregion
