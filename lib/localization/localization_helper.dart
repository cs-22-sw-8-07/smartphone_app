import 'package:flutter/material.dart';
import 'package:smartphone_app/localization/local_app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

class LocalizationHelper {
  ///
  /// STATIC
  ///
  //region Static

  static LocalizationHelper? _localizationHelper;

  static LocalizationHelper getInstance() {
    return _localizationHelper!;
  }

  static init({required BuildContext context}) {
    _localizationHelper = LocalizationHelper();
  }

//endregion

  ///
  /// METHODS
  ///
//region Methods

  Future<String?> getLocalizedResponseError(int errorNo) async {
    String? localizedResponseError;
    AppLocalizations appLocalizations =
        await LocalAppLocalizations.getAppLocalizations();
    switch (errorNo) {
      case 1:
        localizedResponseError = "This is an error";
        break;
    }

    return localizedResponseError;
  }

  Future<String?> getLocalizedQuackLocationType(QuackLocationType qlt) async {
    String? localizedQlt;
    AppLocalizations appLocalizations =
        await LocalAppLocalizations.getAppLocalizations();
    switch (qlt) {
      case QuackLocationType.forest:
        localizedQlt = appLocalizations.recommendations;
        break;
      case QuackLocationType.beach:
        localizedQlt = "Beach";
        break;
    }

    return localizedQlt;
  }

//endregion

}
