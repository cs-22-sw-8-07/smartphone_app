import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/pages/login/login_page.dart';
import 'package:smartphone_app/pages/main/main_page_events_states.dart';
import 'package:smartphone_app/webservices/spotify/service/spotify_service.dart';
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
          var response = await SpotifyService.getInstance().disconnect();
          if (response.isSuccess) {
            GeneralUtil.goToPage(context, const LoginPage());
          }
          break;
        case MainButtonEvent.resizePlaylist:
          emit(state.copyWith(isPlaylistShown: !state.isPlaylistShown!));
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

    // TODO: Do something if there is an error

    return response.resultType;
  }

  Future<bool> getValues() async {
    return true;
  }

//endregion

}
