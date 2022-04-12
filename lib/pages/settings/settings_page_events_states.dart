import 'dart:collection';

import 'package:equatable/equatable.dart';
///
/// ENUMS
///
//region Enums

enum SettingsButtonEvent { back, save, deleteAccount}
//endregion

///
/// EVENT
///
//region Event

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class ButtonPressed extends SettingsEvent {
  final SettingsButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}


class ValuesRetrieved extends SettingsEvent {
  final String? name;
  const ValuesRetrieved({required this.name});

  @override
  List<Object?> get props => [name];
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

  List<String> getNamesOfChangedProperties(
      HashMap<String, int> savedHashCodes) {
    List<String> names = List.empty(growable: true);
    HashMap<String, int> currentHashCodeMap = getCurrentHashCodes();
    for (var pair in currentHashCodeMap.entries) {
      int? savedHashCode = savedHashCodes[pair.key];
      if (savedHashCode == null) continue;
      if (pair.value != savedHashCode) names.add(pair.key);
    }
    return names;
  }

  HashMap<String, int> getCurrentHashCodes({SettingsState? state}) {
    state ??= this;
    HashMap<String, int> hashMap = HashMap();
    return hashMap;
  }

  @override
  List<Object?> get props => [];
}

//endregion