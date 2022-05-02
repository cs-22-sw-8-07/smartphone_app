import 'package:flutter/material.dart';
import 'package:smartphone_app/localization/local_app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
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
    AppLocalizations appLocalizations =
        await LocalAppLocalizations.getAppLocalizations();
    switch (errorNo) {
      case 1:
        return appLocalizations.quack_api_response_error_1;
      case 2:
        return appLocalizations.quack_api_response_error_2;
      case 5:
        return appLocalizations.quack_api_response_error_5;
      case 50:
        return appLocalizations.quack_api_response_error_50;
      case 105:
        return appLocalizations.quack_api_response_error_105;
      case 109:
        return appLocalizations.quack_api_response_error_109;
      case 110:
        return appLocalizations.quack_api_response_error_110;
      case 111:
        return appLocalizations.quack_api_response_error_111;
      case 112:
        return appLocalizations.quack_api_response_error_112;
      case 113:
        return appLocalizations.quack_api_response_error_113;
      case 114:
        return appLocalizations.quack_api_response_error_114;
      case 115:
        return appLocalizations.quack_api_response_error_115;
      case 116:
        return appLocalizations.quack_api_response_error_116;
      case 117:
        return appLocalizations.quack_api_response_error_117;
      case 118:
        return appLocalizations.quack_api_response_error_118;
      case 119:
        return appLocalizations.quack_api_response_error_119;
      case 120:
        return appLocalizations.quack_api_response_error_120;
      case 121:
        return appLocalizations.quack_api_response_error_121;
      case 122:
        return appLocalizations.quack_api_response_error_122;
      case 123:
        return appLocalizations.quack_api_response_error_123;
      case 124:
        return appLocalizations.quack_api_response_error_124;
      case 125:
        return appLocalizations.quack_api_response_error_125;
      case 126:
        return appLocalizations.quack_api_response_error_126;
      case 127:
        return appLocalizations.quack_api_response_error_127;
      case 201:
        return appLocalizations.quack_api_response_error_201;
      case 202:
        return appLocalizations.quack_api_response_error_202;
      case 203:
        return appLocalizations.quack_api_response_error_203;
      case 204:
        return appLocalizations.quack_api_response_error_204;
      case 205:
        return appLocalizations.quack_api_response_error_205;
      case 206:
        return appLocalizations.quack_api_response_error_206;
      default:
        return null;
    }
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
      case QuackLocationType.forest:
        return values.qltForest;
      case QuackLocationType.beach:
        return values.qltBeach;
      case QuackLocationType.nightLife:
        return values.qltNightLife;
      case QuackLocationType.urban:
        return values.qltUrban;
      case QuackLocationType.cemetery:
        return values.qltCemetery;
      case QuackLocationType.education:
        return values.qltEducation;
      case QuackLocationType.church:
        return values.qltChurch;
    }
  }

  String getQuackLocationTypeSmallImagePath(QuackLocationType qlt) {
    switch (qlt) {
      case QuackLocationType.unknown:
        return values.qltUnknownSmall;
      case QuackLocationType.forest:
        return values.qltForestSmall;
      case QuackLocationType.beach:
        return values.qltBeachSmall;
      case QuackLocationType.nightLife:
        return values.qltNightLifeSmall;
      case QuackLocationType.urban:
        return values.qltUrbanSmall;
      case QuackLocationType.cemetery:
        return values.qltCemeterySmall;
      case QuackLocationType.education:
        return values.qltEducationSmall;
      case QuackLocationType.church:
        return values.qltChurchSmall;
    }
  }

//endregion

}
