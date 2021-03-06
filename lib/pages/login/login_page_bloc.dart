import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/login/login_page_events_states.dart';

import '../../helpers/permission_helper.dart';
import '../../services/webservices/spotify/models/spotify_classes.dart';
import '../../services/webservices/spotify/services/spotify_service.dart';
import '../../utilities/general_util.dart';
import '../main/main_page_ui.dart';

class LoginPageBloc extends Bloc<LoginPageEvent, LoginPageState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  /// A [BuildContext] set in the constructor, in order to access UI functionality
  /// such as localization and navigation
  late BuildContext context;

  /// Helper used to ask the user for the [permissions]
  late PermissionHelper permissionHelper;

  /// List of permissions that the app needs in order to fully function
  static const List<PermissionWithService> permissions = [Permission.location];

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  LoginPageBloc({required this.context, required this.permissionHelper})
      : super(LoginPageState(permissionState: PermissionState.denied)) {
    /// ButtonPressed
    on<ButtonPressed>((event, emit) async {
      switch (event.buttonEvent) {

        /// Continue with Spotify
        case LoginButtonEvent.continueWithSpotify:
          SpotifySdkResponseWithResult<String> response =
              await SpotifyService.getInstance().getAuthenticationToken();
          if (!response.isSuccess) {
            GeneralUtil.showToast(response.errorMessage);
            return;
          }
          String token = response.resultType!;
          SpotifyServiceResponse<GetCurrentUsersProfileResponse>
              getCurrentUsersProfileResponse =
              await SpotifyService.getInstance()
                  .getCurrentUsersProfile(token: token);
          if (!getCurrentUsersProfileResponse.isSuccess) {
            GeneralUtil.showToast(response.errorMessage);
            return;
          }

          AppValuesHelper.getInstance()
              .saveString(AppValuesKey.accessToken, token);
          AppValuesHelper.getInstance().saveString(AppValuesKey.email,
              getCurrentUsersProfileResponse.spotifyResponse!.email);
          AppValuesHelper.getInstance().saveString(AppValuesKey.displayName,
              getCurrentUsersProfileResponse.spotifyResponse!.displayName);
          AppValuesHelper.getInstance().saveString(
              AppValuesKey.userImageUrl,
              getCurrentUsersProfileResponse.spotifyResponse!.images!.isEmpty
                  ? ""
                  : getCurrentUsersProfileResponse
                      .spotifyResponse!.images![0].url);
          GeneralUtil.goToPage(context, MainPage());
          break;

        /// Go to settings
        case LoginButtonEvent.goToSettings:
          await permissionHelper.openAppSettings();
          break;
      }
    });

    /// Resumed
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

    /// PermissionStateChanged
    on<PermissionStateChanged>((event, emit) {
      emit(state.copyWith(permissionState: event.permissionState));
    });
  }

//endregion

  ///
  /// METHODS
  ///
//region Methods

  /// Get permissions for the app
  /// Used when starting the app, and when navigating to the login page
  Future<PermissionState> getPermissions() async {
    // On iOS the permissions are granted automatically
    if (Platform.isIOS) {
      return PermissionState.granted;
    }
    // Request permissions
    Map<Permission, PermissionStatus> statuses =
        await permissionHelper.requestPermissions(permissions);
    // Check if all the permissions were granted
    PermissionState permissionState =
        statuses.values.any((element) => !element.isGranted)
            ? PermissionState.denied
            : PermissionState.granted;

    // Update the permission state
    add(PermissionStateChanged(permissionState: permissionState));
    // Return the overall permission state to the caller
    return permissionState;
  }

//endregion

}
