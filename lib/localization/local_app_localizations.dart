import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';

class LocalAppLocalizations {

  static Future<AppLocalizations> getAppLocalizations() async {
    Locale? locale;
    try {
      locale = await Devicelocale.currentAsLocale;
    } on PlatformException {
      return AppLocalizationsEn();
    }
    if (locale == null) {
      return AppLocalizationsEn();
    }

    // Lookup logic when only language code is specified.
    switch (locale.languageCode) {
      case 'en':
        return AppLocalizationsEn();
    }
    return AppLocalizationsEn();
  }
}