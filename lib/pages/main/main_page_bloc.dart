import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/pages/login/login_page.dart';
import 'package:smartphone_app/pages/main/main_page_events_states.dart';
import 'package:smartphone_app/webservices/spotify/service/spotify_service.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/player_state.dart';

import '../../utilities/general_util.dart';

class MainPageBloc extends Bloc<MainPageEvent, MainPageState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext context;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  MainPageBloc({required this.context})
      : super(MainPageState(
            isPlaylistShown: false, isRecommendationStarted: false)) {
    // ButtonPressed
    on<ButtonPressed>((event, emit) async {
      switch (event.buttonEvent) {
        case MainButtonEvent.startStopRecommendation:
          emit(state.copyWith(
              isRecommendationStarted: !state.isRecommendationStarted!));
          break;
        case MainButtonEvent.selectPreferenceProfile:
          // TODO: Handle this case.
          break;
        case MainButtonEvent.seeRecommendations:
          // TODO: Handle this case.
          break;
        case MainButtonEvent.goToSettings:
          // TODO: Handle this case.
          break;
        case MainButtonEvent.logOff:
          GeneralUtil.goToPage(context, const LoginPage());
          break;
        case MainButtonEvent.resizePlaylist:
          emit(state.copyWith(isPlaylistShown: !state.isPlaylistShown!));
          break;
        case MainButtonEvent.resumePausePlayer:
          if (state.playerState == null) {
            // TODO: Show message to user
            return;
          }

          if (state.playerState!.isPaused) {
            SpotifySdkResponse response = await SpotifyService.getInstance().resume();
            if (!response.isSuccess) {
              GeneralUtil.showToast(response.errorMessage);
            }
          } else {
            SpotifySdkResponse response = await SpotifyService.getInstance().pause();
            if (!response.isSuccess) {
              GeneralUtil.showToast(response.errorMessage);
            }
          }

          break;
      }
    });
    // SpotifyPlayerStateChanged
    on<SpotifyPlayerStateChanged>(((event, emit) {
      emit(state.copyWith(playerState: event.playerState));
    }));
    // TouchEvent
    on<TouchEvent>((event, emit) async {
      switch (event.touchEvent) {
        case MainTouchEvent.goToNextTrack:
          SpotifySdkResponse response = await SpotifyService.getInstance().skipNext();
          if (!response.isSuccess) {
            GeneralUtil.showToast(response.errorMessage);
          }
          break;
        case MainTouchEvent.goToPreviousTrack:
          SpotifySdkResponse response = await SpotifyService.getInstance().skipPrevious();
          if (!response.isSuccess) {
            GeneralUtil.showToast(response.errorMessage);
          }
          break;
      }
    });
  }

//endregion

  ///
  /// METHODS
  ///
//region Methods

  Stream<PlayerState>? getPlayerState() {
    var response = SpotifyService.getInstance().subscribePlayerState();
    return response.resultType;
  }

  Stream<ConnectionStatus>? getConnectionStatus() {
    var response = SpotifyService.getInstance().subscribeConnectionStatus();
    return response.resultType;
  }

  Future<bool> getValues() async {
    SpotifySdkResponseWithResult<bool> response =
        await SpotifyService.getInstance().connectToSpotifyRemote();

    return response.isSuccess;
  }

//endregion

}
