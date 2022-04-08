import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/services/webservices/quack/services/quack_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/question_dialog.dart';
import 'package:smartphone_app/pages/settings/settings_page_events_states.dart';

enum SettingsCallBackType { deleteAccount, settingsChanged }

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  ///
  /// VARIABLES
  ///
  //region Variables
  late BuildContext context;
  late HashMap<String, int>? hashCodeMap;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  SettingsBloc({required this.context}) : super(SettingsState()) {
    on<ButtonPressed>((event, emit) async {
      switch (event.buttonEvent) {

        /// Back
        case SettingsButtonEvent.back:
          List<String> names = state.getNamesOfChangedProperties(hashCodeMap!);
          if (names.isNotEmpty) {
            DialogQuestionResponse questionResponse = await QuestionDialog.show(
                context: context,
                question:
                    AppLocalizations.of(context)!.do_you_want_to_save_changes);
            if (questionResponse == DialogQuestionResponse.yes) {
              if (kDebugMode) {
                print("Test");
                Navigator.of(context).pop(null);
              }
              break;
            } else {
              if (kDebugMode) {
                print("you exited!");
                Navigator.of(context).pop(null);
              }
            }
          } else {
            if (kDebugMode) {
              print("you exited! 2");
              Navigator.of(context).pop(null);
            }
          }
          break;

        /// Save
        case SettingsButtonEvent.save:
          await _saveChanges();
          break;

        /// Delete account
        case SettingsButtonEvent.deleteAccount:
          await _deleteAccount();
          break;
      }
    });
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<void> _saveChanges() async {
    //TODO: Give functionality
  }

  Future<void> _deleteAccount() async {
    DialogQuestionResponse questionResponse = await QuestionDialog.show(
        context: context,
        question: AppLocalizations.of(context)!.delete_account_confirmation);
    if (questionResponse != DialogQuestionResponse.yes) return;

    //TODO: Something to delete account
  }
}
