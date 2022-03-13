// ignore: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartphone_app/helpers/permission_helper.dart';
import 'package:smartphone_app/pages/login/login_page_bloc.dart';
import 'package:smartphone_app/pages/login/login_page_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

// ignore: must_be_immutable, use_key_in_widget_constructors
class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  LoginPageBloc? bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ignore: missing_enum_constant_in_switch
    switch (state) {
      case AppLifecycleState.resumed:
        if (bloc != null) {
          bloc!.add(Resumed());
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    bloc =
        LoginPageBloc(context: context, permissionHelper: PermissionHelper());

    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: FutureBuilder<PermissionState>(
            future: bloc!.getPermissions(),
            builder: (context, snapshot) {
              /// Main content shown on the login page
              return BlocProvider(
                  create: (_) => bloc!,
                  child: Container(
                      color: custom_colors.appSafeAreaColor,
                      child: SafeArea(child: Scaffold(
                          body: BlocBuilder<LoginPageBloc, LoginPageState>(
                        builder: (context, state) {
                          return _getBody(context, bloc!, state, snapshot);
                        },
                      )))));
            }));
  }

  Widget _getBody(BuildContext context, LoginPageBloc bloc,
      LoginPageState state, AsyncSnapshot<PermissionState> snapshot) {
    /// Content shown while asking then user for OS permissions like
    /// accessing camera, location etc.
    if (snapshot.connectionState != ConnectionState.done ||
        snapshot.data == null) {
      return Container(
        color: Colors.white,
      );
    }

    /// The user denied one of the permissions
    if (state.permissionState == PermissionState.denied &&
        snapshot.data! == PermissionState.denied) {
      return Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomLabel(
              title: AppLocalizations.of(context)!
                  .please_go_to_settings_and_give_the_app_all_the_necessary_permissions,
            ),
            CustomButton(
              defaultBackground: custom_colors.blackGradient,
              pressedBackground: custom_colors.blackPressedGradient,
              onPressed: () => bloc.add(const ButtonPressed(
                  buttonEvent: LoginButtonEvent.goToSettings)),
              text: AppLocalizations.of(context)!.go_to_settings,
              borderRadius: const BorderRadius.all(Radius.circular(27.5)),
              textColor: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              margin: const EdgeInsets.only(
                  left: 30, right: 30, top: values.padding),
            )
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(gradient: custom_colors.loginBackground),
      child: _getContent(context, bloc),
    );
  }

  Widget _getContent(BuildContext context, LoginPageBloc bloc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomLabel(
          title: AppLocalizations.of(context)!.app_name,
          fontSize: 35,
          margin: const EdgeInsets.only(bottom: 30, left: 10, right: 10),
          alignmentGeometry: Alignment.center,
          fontWeight: FontWeight.bold,
        ),
        Container(
            margin: const EdgeInsets.only(bottom: 50, left: 5, right: 5),
            child: SvgPicture.asset(
              values.appFeatureImage,
              fit: BoxFit.contain,
              height: 160,
            )),
        CustomButton(
          text: AppLocalizations.of(context)!.continue_with_spotify,
          fontWeight: FontWeight.bold,
          image: const AssetImage("assets/spotify_icon.png"),
          imagePadding: const EdgeInsets.all(15),
          onPressed: () => bloc.add(const ButtonPressed(
              buttonEvent: LoginButtonEvent.continueWithSpotify)),
          textColor: custom_colors.black,
          pressedBackground: custom_colors.spotifyPressedGradient,
          defaultBackground: custom_colors.spotifyGradient,
          margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
        ),
      ],
    );
  }
}
