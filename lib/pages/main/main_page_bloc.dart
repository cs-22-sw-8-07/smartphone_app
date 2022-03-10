import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/login/login_page.dart';
import 'package:smartphone_app/pages/main/main_page_events_states.dart';
import 'package:smartphone_app/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/webservices/quack/service/quack_service.dart';
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
            hasJustSkipped: false,
            isPlaylistShown: false,
            isRecommendationStarted: false)) {
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

          await resumePausePlayer();

          break;
      }
    });
    // SpotifyPlayerStateChanged
    on<SpotifyPlayerStateChanged>(((event, emit) {
      if (state.playerState == null || event.playerState == null) {
        emit(state.copyWith(playerState: event.playerState));
        return;
      }

      QuackTrack? trackFromPreviousPlayerState =
          QuackTrack.trackToQuackTrack(state.playerState!.track);
      QuackTrack? trackFromCurrentPlayerState =
          QuackTrack.trackToQuackTrack(event.playerState!.track);

      if (state.hasJustSkipped! ||
          trackFromCurrentPlayerState == trackFromPreviousPlayerState) {
        emit(state.copyWith(
            playerState: event.playerState, hasJustSkipped: false));
      } else {
        if (state.playlist == null || trackFromPreviousPlayerState == null) {
          emit(state.copyWith(playerState: event.playerState));
          return;
        }

        int index =
            state.playlist!.tracks!.indexOf(trackFromPreviousPlayerState);
        if (index != -1) {
          playNextTrack(index);
        }
        emit(state.copyWith(playerState: event.playerState));
      }
    }));
    // TouchEvent
    on<TouchEvent>((event, emit) async {
      QuackTrack? currentlyPlayingTrack =
          QuackTrack.trackToQuackTrack(state.playerState!.track!);

      if (state.playlist!.tracks!.contains(currentlyPlayingTrack)) {
        int index = state.playlist!.tracks!.indexOf(currentlyPlayingTrack!);
        switch (event.touchEvent) {
          case MainTouchEvent.goToNextTrack:
            {
              var response = await playNextTrack(index);
              if (!response.isSuccess) {
                return;
              }
              break;
            }
          case MainTouchEvent.goToPreviousTrack:
            {
              QuackTrack? previousTrack;
              if (index == 0) {
                previousTrack =
                    state.playlist!.tracks![state.playlist!.tracks!.length - 1];
              } else {
                previousTrack = state.playlist!.tracks![index - 1];
              }

              SpotifySdkResponse response = await SpotifyService.getInstance()
                  .playTrack(previousTrack.id!);
              if (!response.isSuccess) {
                GeneralUtil.showToast(response.errorMessage);
                return;
              }
              break;
            }
        }
        emit(state.copyWith(hasJustSkipped: true));
      } else {
        switch (event.touchEvent) {
          case MainTouchEvent.goToNextTrack:
            SpotifySdkResponse response =
                await SpotifyService.getInstance().skipNext();
            if (!response.isSuccess) {
              GeneralUtil.showToast(response.errorMessage);
              return;
            }
            emit(state.copyWith(hasJustSkipped: true));
            break;
          case MainTouchEvent.goToPreviousTrack:
            SpotifySdkResponse response =
                await SpotifyService.getInstance().skipPrevious();
            if (!response.isSuccess) {
              GeneralUtil.showToast(response.errorMessage);
              return;
            }
            break;
        }
        emit(state.copyWith(hasJustSkipped: true));
      }
    });
    // PlaylistReceived
    on<PlaylistReceived>((event, emit) {
      emit(state.copyWith(playlist: event.playList));
    });
    // PlayPauseTrack
    on<PlayPauseTrack>((event, emit) async {
      QuackTrack? currentlyPlayingTrack =
          QuackTrack.trackToQuackTrack(state.playerState!.track!);
      if (event.quackTrack == currentlyPlayingTrack) {
        resumePausePlayer();
      } else {
        SpotifySdkResponse response =
            await SpotifyService.getInstance().playTrack(event.quackTrack.id!);
        if (!response.isSuccess) {
          GeneralUtil.showToast(response.errorMessage);
        }
      }
    });
  }

//endregion

  ///
  /// METHODS
  ///
//region Methods

  Future<SpotifySdkResponse> playNextTrack(int index) async {
    QuackTrack? nextTrack;
    if (index == state.playlist!.tracks!.length - 1) {
      nextTrack = state.playlist!.tracks![0];
    } else {
      nextTrack = state.playlist!.tracks![index + 1];
    }

    SpotifySdkResponse response =
        await SpotifyService.getInstance().playTrack(nextTrack.id!);
    if (!response.isSuccess) {
      GeneralUtil.showToast(response.errorMessage);
    }
    return response;
  }

  Future<void> resumePausePlayer() async {
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
  }

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
    if (!response.isSuccess) {
      return false;
    }

    var accessToken =
        AppValuesHelper.getInstance().getString(AppValuesKey.accessToken);
    QuackServiceResponse<GetPlaylistResponse> getPlaylistResponse =
        await QuackService.getInstance()
            .getPlaylist(accessToken, QuackLocationType.beach);
    if (!getPlaylistResponse.isSuccess) {
      return false;
    }

    // Call event
    add(PlaylistReceived(playList: getPlaylistResponse.quackResponse!.result));

    return true;
  }

//endregion

}
