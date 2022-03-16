import 'package:flutter/material.dart';
import 'package:smartphone_app/localization/local_app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/values/values.dart';
import 'package:smartphone_app/values/values.dart' as values;

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

  String getLocalizedQuackLocationType(
      BuildContext context, QuackLocationType qlt) {
    String localizedQlt = "";
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    switch (qlt) {
      case QuackLocationType.forest:
        localizedQlt = appLocalizations.forest;
        break;
      case QuackLocationType.beach:
        localizedQlt = appLocalizations.beach;
        break;
      case QuackLocationType.unknown:
        localizedQlt = appLocalizations.unknown;
        break;
      case QuackLocationType.nightLife:
        localizedQlt = appLocalizations.night_life;
        break;
      case QuackLocationType.urban:
        localizedQlt = appLocalizations.urban;
        break;
      case QuackLocationType.cemetery:
        localizedQlt = appLocalizations.cemetery;
        break;
      case QuackLocationType.education:
        localizedQlt = appLocalizations.education;
        break;
      case QuackLocationType.church:
        localizedQlt = appLocalizations.church;
        break;
    }

    return localizedQlt;
  }

  String getQuackLocationTypeImagePath(QuackLocationType qlt) {
    switch (qlt) {
      case QuackLocationType.unknown:
        return values.qltUnknown;
        break;
      case QuackLocationType.forest:
        return values.qltForest;
        break;
      case QuackLocationType.beach:
        return values.qltBeach;
        break;
      case QuackLocationType.nightLife:
        return values.qltNightLife;
        break;
      case QuackLocationType.urban:
        return values.qltUrban;
        break;
      case QuackLocationType.cemetery:
        return values.qltCemetery;
        break;
      case QuackLocationType.education:
        return values.qltEducation;
        break;
      case QuackLocationType.church:
        return values.qltChurch;
        break;
    }
    return qltBeach;
  }

//endregion

}
