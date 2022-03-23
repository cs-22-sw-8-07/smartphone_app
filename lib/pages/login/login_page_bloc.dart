import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/login/login_page_events_states.dart';

import '../../helpers/permission_helper.dart';
import '../../services/webservices/spotify/models/spotify_classes.dart';
import '../../services/webservices/spotify/services/spotify_service.dart';
import '../../utilities/general_util.dart';
import '../main/old/main_page_2.dart';

class LoginPageBloc extends Bloc<LoginPageEvent, LoginPageState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext context;
  late PermissionHelper permissionHelper;
  static const List<PermissionWithService> permissions = [
    Permission.locationWhenInUse,
    Permission.locationAlways,
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
          String token = response.resultType!;
          SpotifyServiceResponse<GetCurrentUsersProfileResponse>
              getCurrentUsersProfileResponse =
              await SpotifyService.getInstance()
                  .getCurrentUsersProfile(token: token);
          if (!getCurrentUsersProfileResponse.isSuccess) {
            Fluttertoast.showToast(msg: response.exception!);
            return;
          }

          AppValuesHelper.getInstance()
              .saveString(AppValuesKey.accessToken, token);
          AppValuesHelper.getInstance().saveString(AppValuesKey.email,
              getCurrentUsersProfileResponse.spotifyResponse!.email);
          AppValuesHelper.getInstance().saveString(AppValuesKey.displayName,
              getCurrentUsersProfileResponse.spotifyResponse!.displayName);
          AppValuesHelper.getInstance().saveString(AppValuesKey.userImageUrl,
              getCurrentUsersProfileResponse.spotifyResponse!.images![0].url);
          GeneralUtil.goToPage(context, const MainPage2());
          break;
        case LoginButtonEvent.goToSettings:
          await permissionHelper.openAppSettings();
          break;
      }
    });
    on<Resumed>((event, emit) async {
      for (var permission in permissions) {
        var status = await permissionHelper.getStatus(permission);
        if (!status.isGranted) {
          add(const PermissionStateChanged(
              permissionState: PermissionState.denied));
          return;
        }
      }
      add(const PermissionStateChanged(
          permissionState: PermissionState.granted));
    });
    on<PermissionStateChanged>((event, emit) {
      emit(state.copyWith(permissionState: event.permissionState));
    });
  }

//endregion

  ///
  /// METHODS
  ///
//region Methods

  Future<PermissionState> getPermissions() async {
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
