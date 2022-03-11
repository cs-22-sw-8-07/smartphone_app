import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smartphone_app/pages/login/login_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/pages/main/main_page.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/webservices/quack/service/mock_quack_service.dart';
import 'package:smartphone_app/webservices/quack/service/quack_service.dart';
import 'package:smartphone_app/webservices/spotify/service/spotify_service.dart';

import 'helpers/app_values_helper.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await AppValuesHelper.getInstance().init();
  SpotifyService.init(SpotifyService());
  QuackService.init(MockQuackService());

  // Pre-cache SVG
  await Future.wait([
    precachePicture(
      ExactAssetPicture(
          SvgPicture.svgStringDecoderBuilder, values.appFeatureImage),
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //LocalizationHelper.init(context: context);

    var localizations = [AppLocalizations.localizationsDelegates]
        .expand((element) => element)
        .toList();

    String? token = AppValuesHelper.getInstance().getString(AppValuesKey.accessToken);
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
        home: token == null ? const LoginPage() : const MainPage());
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
