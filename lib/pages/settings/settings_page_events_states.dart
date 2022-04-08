import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

///
/// ENUMS
///
//region Enums

enum SettingsButtonEvent { back, save, deleteAccount}
enum SettingsTextChangedEvent { name }

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

class TextChanged extends SettingsEvent {
  final SettingsTextChangedEvent textChangedEvent;
  final String? text;

  const TextChanged({required this.textChangedEvent, required this.text});

  @override
  List<Object?> get props => [textChangedEvent, text];
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
  String? name;

  SettingsState({this.name});

  SettingsState copyWith({String? name}) {
    return SettingsState(
        name: name ?? this.name);
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
    hashMap["Name"] = state.name.hashCode;
    return hashMap;
  }

  @override
  List<Object?> get props => [name];
}

//endregion