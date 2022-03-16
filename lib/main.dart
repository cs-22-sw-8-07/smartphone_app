import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartphone_app/pages/login/login_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/pages/main/main_page.dart';
import 'package:smartphone_app/pages/main/main_page_2.dart';
import 'package:smartphone_app/services/quack_location_service/service/quack_location_service.dart';
import 'package:smartphone_app/services/webservices/foursquare/service/foursquare_service.dart';
import 'package:smartphone_app/services/webservices/quack/service/mock_quack_service.dart';
import 'package:smartphone_app/services/webservices/quack/service/quack_service.dart';
import 'package:smartphone_app/services/webservices/spotify/service/spotify_service.dart';
import 'package:smartphone_app/values/values.dart' as values;

import 'helpers/app_values_helper.dart';
import 'localization/localization_helper.dart';

void main() async {
  await dotenv.load();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await AppValuesHelper.getInstance().init();
  SpotifyService.init(SpotifyService());
  QuackService.init(MockQuackService());
  FoursquareService.init(FoursquareService());
  QuackLocationService.init(QuackLocationService());

  // Pre-cache SVG
  await Future.wait([
    precachePicture(
      ExactAssetPicture(
          SvgPicture.svgStringDecoderBuilder, values.appFeatureImage2),
      null,
    ),
    // other SVGs or images here
  ]);

  runApp(const MyApp());
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class MyApp extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const MyApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //LocalizationHelper.init(context: context);

    var localizations = [AppLocalizations.localizationsDelegates]
        .expand((element) => element)
        .toList();

    String? token =
        AppValuesHelper.getInstance().getString(AppValuesKey.accessToken);
    if (token == "") {
      token = null;
    }

    return MaterialApp(
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: child!,
          );
        },
        localizationsDelegates: localizations,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: token == null ? const LoginPage() : const MainPage2());
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
