import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/localization/localization_helper.dart';
import 'package:smartphone_app/pages/login/login_page.dart';
import 'package:smartphone_app/pages/main/main_page_events_states.dart';
import 'package:smartphone_app/services/quack_location_service/service/quack_location_service.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;

// ignore: unnecessary_import, implementation_imports
import 'package:geolocator_android/src/types/foreground_settings.dart';

import '../../helpers/position_helper/mock_position_helper.dart';
import '../../helpers/position_helper/position_helper.dart';
import '../../services/webservices/quack/models/quack_classes.dart';
import '../../services/webservices/quack/service/quack_service.dart';
import '../../services/webservices/spotify/service/spotify_service.dart';
import '../../utilities/general_util.dart';

class MainPageBloc extends Bloc<MainPageEvent, MainPageState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext context;
  PositionHelper? positionHelper;
  late StreamSubscription<Position?> positionStreamSubscription;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  MainPageBloc({required this.context})
      : super(MainPageState(
            hasJustPerformedAction: false,
            isPlaylistShown: false,
            isLoading: false,
            quackLocationType: QuackLocationType.unknown,
            isRecommendationStarted: false)) {
    /// ButtonPressed
    on<ButtonPressed>((event, emit) async {
      switch (event.buttonEvent) {
        case MainButtonEvent.startStopRecommendation:
          if (state.isRecommendationStarted!) {
            emit(state.copyWith(
                isLoading: true, isRecommendationStarted: false));
            await SpotifyService.getInstance().pause();
            var newState = state.copyWith(isLoading: false);
            newState.playlist = null;
            emit(newState);
          } else {
            await _startRecommendation();
          }
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
          AppValuesHelper.getInstance()
              .saveString(AppValuesKey.accessToken, "");

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
          await _resumePausePlayer();
          emit(state.copyWith(hasJustPerformedAction: true));
          break;
        case MainButtonEvent.lockUnlockQuackLocationType:
          String message = "";

          if (state.lockedQuackLocationType == null) {
            emit(state.copyWith(
                lockedQuackLocationType: state.quackLocationType));
            message = AppLocalizations.of(context)!.locked_location;
          } else {
            var newState = state.copyWith();
            newState.lockedQuackLocationType = null;
            emit(newState);
            message = AppLocalizations.of(context)!.unlocked_location;
          }

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.white,
              content: Text(
                message,
                style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              )));
          break;
      }
    });

    /// SpotifyPlayerStateChanged
    on<SpotifyPlayerStateChanged>(((event, emit) {
      if (state.playerState == null || event.playerState == null) {
        emit(state.copyWith(playerState: event.playerState));
        return;
      }

      QuackTrack? trackFromPreviousPlayerState =
          QuackTrack.trackToQuackTrack(state.playerState!.track);
      QuackTrack? trackFromCurrentPlayerState =
          QuackTrack.trackToQuackTrack(event.playerState!.track);

      if (state.hasJustPerformedAction! ||
          trackFromCurrentPlayerState == trackFromPreviousPlayerState) {
        emit(state.copyWith(
            playerState: event.playerState, hasJustPerformedAction: false));
      } else {
        if (state.playlist == null || trackFromPreviousPlayerState == null) {
          emit(state.copyWith(playerState: event.playerState));
          return;
        }

        int index =
            state.playlist!.tracks!.indexOf(trackFromPreviousPlayerState);
        if (index != -1) {
          _playNextTrack(index);
        }
        emit(state.copyWith(playerState: event.playerState));
      }
    }));

    /// TouchEvent
    on<TouchEvent>((event, emit) async {
      QuackTrack? currentlyPlayingTrack =
          QuackTrack.trackToQuackTrack(state.playerState!.track!);

      if (state.playlist != null &&
          state.playlist!.tracks!.contains(currentlyPlayingTrack)) {
        int index = state.playlist!.tracks!.indexOf(currentlyPlayingTrack!);
        switch (event.touchEvent) {
          case MainTouchEvent.goToNextTrack:
            {
              var response = await _playNextTrack(index);
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
        emit(state.copyWith(hasJustPerformedAction: true));
      } else {
        switch (event.touchEvent) {
          case MainTouchEvent.goToNextTrack:
            SpotifySdkResponse response =
                await SpotifyService.getInstance().skipNext();
            if (!response.isSuccess) {
              GeneralUtil.showToast(response.errorMessage);
              return;
            }
            emit(state.copyWith(hasJustPerformedAction: true));
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
        emit(state.copyWith(hasJustPerformedAction: true));
      }
    });

    /// PlaylistReceived
    on<PlaylistReceived>((event, emit) {
      emit(state.copyWith(playlist: event.playList));
    });

    /// TrackSelected
    on<TrackSelected>((event, emit) async {
      SpotifySdkResponse response =
          await SpotifyService.getInstance().playTrack(event.quackTrack.id!);
      if (!response.isSuccess) {
        GeneralUtil.showToast(response.errorMessage);
        return;
      }
      emit(state.copyWith(hasJustPerformedAction: true));
    });

    /// IsLoadingPlaylistChanged
    on<IsLoadingChanged>((event, emit) {
      emit(state.copyWith(isLoading: event.isLoading));
    });

    /// IsRecommendationStartedChanged
    on<IsRecommendationStartedChanged>((event, emit) {
      emit(state.copyWith(
          isRecommendationStarted: event.isRecommendationStarted));
    });

    /// QuackLocationTypeChanged
    on<QuackLocationTypeChanged>((event, emit) {
      if (kDebugMode) {
        print("QLT state change");
      }
      emit(state.copyWith(quackLocationType: event.quackLocationType));
    });

    _subscribeToConnectionStatus();
    _subscribeToPosition();
  }

//endregion

  ///
  /// OVERRIDE METHODS
  ///
  //Region Override methods

  @override
  Future<void> close() async {
    try {
      positionStreamSubscription.cancel();
      if (positionHelper != null) {
        positionHelper!.dispose();
      }
      await SpotifyService.getInstance().disconnect();
      // ignore: empty_catches
    } on Exception {}
    return super.close();
  }

  //endregion

  ///
  /// METHODS
  ///
//region Methods

  void _subscribeToPosition() async {
    positionHelper = MockPositionHelper(
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            forceLocationManager: true,
            intervalDuration: const Duration(seconds: 10),
            //(Optional) Set foreground notification config to keep the app alive
            //when going to the background
            foregroundNotificationConfig: ForegroundNotificationConfig(
              notificationIcon: const AndroidResource(
                  name: "notification_icon", defType: "drawable"),
              notificationText:
                  AppLocalizations.of(context)!.getting_location_in_background,
              notificationTitle: AppLocalizations.of(context)!.app_name,
              enableWakeLock: true,
            )),
        appleSettings: AppleSettings(
          accuracy: LocationAccuracy.high,
          activityType: ActivityType.fitness,
          distanceFilter: 100,
          pauseLocationUpdatesAutomatically: true,
          // Only set to true if our app will be started up in the background.
          showBackgroundLocationIndicator: false,
        ));

    bool gettingLocationType = false;

    positionStreamSubscription =
        positionHelper!.getPositionStream().listen((position) async {
      if (kDebugMode) {
        print(position != null
            ? (position.latitude.toString().replaceAll(",", ".") +
                ", " +
                position.longitude.toString().replaceAll(",", "."))
            : "Unknown");
      }

      if (position != null && !gettingLocationType) {
        gettingLocationType = true;
        QuackLocationType? qlt = await QuackLocationService.getInstance()
            .getQuackLocationType(position);

        if (kDebugMode) {
          print("QLT: " +
              (qlt == null
                  ? "null"
                  : LocalizationHelper.getInstance()
                      .getLocalizedQuackLocationType(context, qlt)));
        }

        if (qlt != null) {
          add(QuackLocationTypeChanged(quackLocationType: qlt));
        }

        gettingLocationType = false;
      }
    });
  }

  void _subscribeToConnectionStatus() {
    SpotifySdkResponseWithResult<Stream<ConnectionStatus>>
        subscribeConnectionStatus =
        SpotifyService.getInstance().subscribeConnectionStatus();

    Stream<ConnectionStatus>? connectionStatusStream =
        subscribeConnectionStatus.resultType;
    connectionStatusStream!.listen((connectionStatus) async {
      if (kDebugMode) {
        print("Spotify connected: " + connectionStatus.connected.toString());
      }
      if (connectionStatus.connected) {
        SpotifySdkResponseWithResult<Stream<PlayerState>> subscribePlayerState =
            SpotifyService.getInstance().subscribePlayerState();

        if (!subscribePlayerState.isSuccess) {
          return;
        }

        subscribePlayerState.resultType!.listen((playerState) {
          add(SpotifyPlayerStateChanged(playerState: playerState));
        });
      } else {
        await _connectToSpotifyRemote();
      }
    });
  }

  Future<SpotifySdkResponse> _playNextTrack(int index) async {
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

  Future<void> _resumePausePlayer() async {
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

  Future<void> _getPlaylist() async {
    var accessToken =
        AppValuesHelper.getInstance().getString(AppValuesKey.accessToken);
    QuackServiceResponse<GetPlaylistResponse> getPlaylistResponse =
        await QuackService.getInstance()
            .getPlaylist(accessToken, QuackLocationType.forest);
    if (!getPlaylistResponse.isSuccess) {
      return;
    }

    add(PlaylistReceived(playList: getPlaylistResponse.quackResponse!.result));
  }

  Stream<PlayerState>? getPlayerState() {
    var response = SpotifyService.getInstance().subscribePlayerState();
    return response.resultType;
  }

  Future<bool> _connectToSpotifyRemote() async {
    SpotifySdkResponseWithResult<bool> response =
        await SpotifyService.getInstance().connectToSpotifyRemote();
    if (!response.isSuccess) {
      return false;
    }
    return response.resultType!;
  }

  Future<bool> _disconnectFromSpotifyRemote() async {
    SpotifySdkResponseWithResult<bool> response =
        await SpotifyService.getInstance().disconnect();
    if (!response.isSuccess) {
      return false;
    }
    return response.resultType!;
  }

  Future<void> _startRecommendation() async {
    add(const IsLoadingChanged(isLoading: true));

    await Future.delayed(const Duration(seconds: 2));

    await _getPlaylist();

    add(const IsLoadingChanged(isLoading: false));
    add(const IsRecommendationStartedChanged(isRecommendationStarted: true));
  }

  Future<bool> getValues() async {
    if (!(await _connectToSpotifyRemote())) {
      return false;
    }

    //await _getPlaylist();

    return true;
  }

//endregion

}
