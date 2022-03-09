import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/login/login_page_events_states.dart';
import 'package:smartphone_app/pages/main/main_page.dart';
import 'package:smartphone_app/webservices/spotify/service/spotify_service.dart';
import 'package:spotify_sdk/models/player_state.dart';

import '../../helpers/permission_helper.dart';
import '../../utilities/general_util.dart';

class LoginPageBloc extends Bloc<LoginPageEvent, LoginPageState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext context;
  late PermissionHelper permissionHelper;
  static const List<PermissionWithService> permissions = [
    Permission.locationWhenInUse
  ];

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  LoginPageBloc({required this.context, required this.permissionHelper})
      : super(LoginPageState(permissionState: PermissionState.denied)) {
    // ButtonPressed
    on<ButtonPressed>((event, emit) async {
      switch (event.buttonEvent) {
        case LoginButtonEvent.continueWithSpotify:
          SpotifySdkResponseWithResult<String> response =
              await SpotifyService.getInstance().getAuthenticationToken();
          if (!response.isSuccess) {
            Fluttertoast.showToast(msg: response.exception!);
            return;
          }
          SpotifySdkResponseWithResult<PlayerState> response2 = await SpotifyService.getInstance().getPlayerState();

          AppValuesHelper.getInstance()
              .saveString(AppValuesKey.accessToken, response.resultType);
          GeneralUtil.goToPage(context, const MainPage());
          break;
        case LoginButtonEvent.goToSettings:
          // TODO: Handle this case.

          break;
      }
    });
    on<Resumed>((event, emit) {

    });
  }

//endregion

  ///
  /// METHODS
  ///
//region Methods

  Future<PermissionState> getPermissions() async {
    return PermissionState.granted;
    if (Platform.isIOS) {
      return PermissionState.granted;
    }

    Map<Permission, PermissionStatus> statuses =
        await permissionHelper.requestPermissions(permissions);

    PermissionState permissionState =
        statuses.values.any((element) => !element.isGranted)
            ? PermissionState.denied
            : PermissionState.granted;

    add(PermissionStateChanged(permissionState: permissionState));
    return permissionState;
  }

//endregion

}
