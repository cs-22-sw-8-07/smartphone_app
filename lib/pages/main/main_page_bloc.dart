import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/localization/localization_helper.dart';
import 'package:smartphone_app/pages/login/login_page_ui.dart';
import 'package:smartphone_app/pages/main/main_page_events_states.dart';
import 'package:smartphone_app/services/quack_location_service/service/quack_location_service.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: unnecessary_import, implementation_imports
import 'package:geolocator_android/src/types/foreground_settings.dart';

import '../../helpers/position_helper/udp_position_helper.dart';
import '../../helpers/position_helper/position_helper.dart';
import '../../services/webservices/quack/models/quack_classes.dart';
import '../../services/webservices/quack/services/quack_service.dart';
import '../../services/webservices/spotify/services/spotify_service.dart';
import '../../utilities/general_util.dart';
import '../settings/settings_page_ui.dart';
import '../settings/settings_page_bloc.dart';

class MainPageBloc extends Bloc<MainPageEvent, MainPageState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext context;
  PositionHelper positionHelper;
  late StreamSubscription<Position?> positionStreamSubscription;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  MainPageBloc({required this.context, required this.positionHelper})
      : super(MainPageState(
            hasJustPerformedAction: false,
            isPlaylistShown: false,
            isLoading: false,
            quackLocationType: QuackLocationType.unknown,
            isRecommendationStarted: false)) {
    LocalizationHelper.init(context: context);

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
        case MainButtonEvent.seeRecommendations:
          // TODO: Handle this case.
          break;
        case MainButtonEvent.goToSettings:
          GeneralUtil.showPageAsDialog(context, SettingsPage());
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

          // Show message to the user
          GeneralUtil.showSnackBar(context: context, message: message);
          break;
        case MainButtonEvent.selectManualLocation:
          if (kDebugMode) {
            print("Test");
          }
          break;
      }
    });

    /// SpotifyPlayerStateChanged
    on<SpotifyPlayerStateChanged>(((event, emit) async {
      if (state.playerState == null || event.playerState == null) {
        emit(state.copyWith(playerState: event.playerState));
        return;
      }

      QuackTrack? trackFromPreviousPlayerState =
          QuackTrack.trackToQuackTrack(state.playerState!.track);
      QuackTrack? trackFromCurrentPlayerState =
          QuackTrack.trackToQuackTrack(event.playerState!.track);

      if (state.hasJustPerformedAction! ||
          trackFromCurrentPlayerState == trackFromPreviousPlayerState ||
          (state.currentTrack != null &&
              trackFromCurrentPlayerState != null &&
              trackFromCurrentPlayerState.id == state.currentTrack!.id)) {
        emit(state.copyWith(
            playerState: event.playerState, hasJustPerformedAction: false));
      } else {
        if (state.playlist == null || trackFromPreviousPlayerState == null) {
          emit(state.copyWith(playerState: event.playerState));
          return;
        }

        emit(state.copyWith(playerState: event.playerState));

        if (state.currentTrack != null) {
          int index = state.playlist!.tracks!.indexOf(state.currentTrack!);

          if (kDebugMode) {
            print("PlayerState Index: " + index.toString());
          }

          // The QuackLocationType has changed, meaning the playlist has
          // been overridden
          if (index == -1) {
            await _playTrack(state.playlist!.tracks!.first);
            return;
          }

          var nextTrack = getNextTrack(state.currentTrack!);
          await _playTrack(nextTrack!);

          if (state.isRecommendationStarted! &&
              index == state.playlist!.tracks!.length - 2) {
            QuackServiceResponse<GetPlaylistResponse> getPlaylistResponse =
                await _getPlaylist();
            if (!getPlaylistResponse.isSuccess) {
              return;
            }
            QuackPlaylist newPlaylist =
                getPlaylistResponse.quackResponse!.result!;
            QuackPlaylist currentPlaylist = state.playlist!;
            // Same QuackLocationType as the current playlist
            if (newPlaylist.quackLocationType ==
                currentPlaylist.quackLocationType) {
              currentPlaylist.tracks!.addAll(newPlaylist.tracks!);
              add(PlaylistReceived(playList: currentPlaylist));
            }
            // New QuackLocationType
            else {
              add(PlaylistReceived(playList: newPlaylist));
            }
          }
        }
      }
    }));

    /// TouchEvent
    on<TouchEvent>((event, emit) async {
      if (state.playlist != null && state.currentTrack != null) {
        int index = state.playlist!.tracks!.indexOf(state.currentTrack!);
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

              SpotifySdkResponse response = await _playTrack(previousTrack);
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
      SpotifySdkResponse response = await _playTrack(event.quackTrack);
      if (!response.isSuccess) {
        GeneralUtil.showToast(response.errorMessage);
        return;
      }
      emit(state.copyWith(hasJustPerformedAction: true));
    });

    /// MainPageValueChanged
    on<MainPageValueChanged>((event, emit) {
      if (kDebugMode) {
        if (event.quackLocationType != null) {
          print("QLT state change");
        }
      }

      var newState = state.copyWith(
          quackLocationType: event.quackLocationType ?? state.quackLocationType,
          isRecommendationStarted:
              event.isRecommendationStarted ?? state.isRecommendationStarted,
          isLoading: event.isLoading ?? state.isLoading);
      newState.currentTrack = event.currentTrack ?? state.currentTrack;
      emit(newState);
    });

    /// HasJustPerformedSpotifyPlayerAction
    on<HasPerformedSpotifyPlayerAction>((event, emit) {
      emit(state.copyWith(hasJustPerformedAction: true));
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
      positionHelper.dispose();
      await _disconnectFromSpotifyRemote();
      // ignore: empty_catches
    } on Exception {}
    return super.close();
  }

  //endregion

  ///
  /// METHODS
  ///
//region Methods

  //region Streams

  /// Subscribe to a stream providing GPS positions
  /// Called once in the constructor of the Bloc
  void _subscribeToPosition() async {
    bool gettingLocationType = false;

    positionStreamSubscription =
        positionHelper.getPositionStream().listen((position) async {
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
          if (state.isRecommendationStarted! &&
              state.quackLocationType != qlt) {
            QuackServiceResponse<GetPlaylistResponse> response =
                await _getPlaylist();
            if (!response.isSuccess) {
              return;
            }
            add(PlaylistReceived(playList: response.quackResponse!.result!));
          }
          add(MainPageValueChanged(quackLocationType: qlt));
        }

        gettingLocationType = false;
      }
    });
  }

  /// Subscribe to the Spotify remote connection status
  /// Called once in the constructor of the Bloc
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

  /// Get player state stream
  /// It has to be refreshed every time you connect to Spotify remote
  Stream<PlayerState>? getPlayerState() {
    var response = SpotifyService.getInstance().subscribePlayerState();
    return response.resultType;
  }

  //endregion

  //region Helper methods

  /// Get next track in the playlist
  /// It is found through the index of the given [track]
  QuackTrack? getNextTrack(QuackTrack track) {
    int index = state.playlist!.tracks!.indexOf(track);
    if (index != -1) {
      if (index == state.playlist!.tracks!.length - 1) {
        return state.playlist!.tracks![0];
      } else {
        return state.playlist!.tracks![index + 1];
      }
    }
    return null;
  }

  //endregion

  //region Player actions

  /// Play a given [track]
  /// [hasPerformedAction] indicates that when the PlayerState changes we know
  /// it is us who have caused it
  Future<SpotifySdkResponse> _playTrack(QuackTrack track,
      {bool hasPerformedAction = true}) async {
    if (hasPerformedAction) {
      add(const HasPerformedSpotifyPlayerAction());
    }
    add(MainPageValueChanged(currentTrack: track));
    SpotifySdkResponse response =
        await SpotifyService.getInstance().playTrack(track.id!);
    return response;
  }

  /// Play next track in the playlist
  /// You have to provide the [index] of the track currently being played
  Future<SpotifySdkResponse> _playNextTrack(int index,
      {bool hasPerformedAction = true}) async {
    QuackTrack? nextTrack = getNextTrack(state.playlist!.tracks![index]);
    return await _playTrack(nextTrack!, hasPerformedAction: hasPerformedAction);
  }

  /// Resume/Pause Spotify player
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

  /// Connect to the Spotify remote
  ///
  /// Returns: True if succeeded else false
  Future<bool> _connectToSpotifyRemote() async {
    SpotifySdkResponseWithResult<bool> response =
        await SpotifyService.getInstance().connectToSpotifyRemote();
    if (!response.isSuccess) {
      return false;
    }
    return response.resultType!;
  }

  /// Disconnect from the Spotify remote
  ///
  /// Returns: True if succeeded else false
  Future<bool> _disconnectFromSpotifyRemote() async {
    SpotifySdkResponseWithResult<bool> response =
        await SpotifyService.getInstance().disconnect();
    if (!response.isSuccess) {
      return false;
    }
    return response.resultType!;
  }

  //endregion

  //region Data gathering

  /// Get playlist from Quack API
  ///
  /// Returns: The response from the Quack API
  Future<QuackServiceResponse<GetPlaylistResponse>> _getPlaylist() async {
    // Get playlist from Quack API
    QuackServiceResponse<GetPlaylistResponse> getPlaylistResponse =
        await QuackService.getInstance().getPlaylist(
            state.lockedQuackLocationType == null
                ? state.quackLocationType!
                : state.lockedQuackLocationType!);
    // If response is success then give every track a unique key
    if (getPlaylistResponse.isSuccess) {
      if (kDebugMode) {
        print("Playlist received");
      }

      for (var track in getPlaylistResponse.quackResponse!.result!.tracks!) {
        track.key = UniqueKey();
      }
    } else {
      if (kDebugMode) {
        print("Playlist received with errors");
      }
    }

    // Return response
    return getPlaylistResponse;
  }

  /// Start recommendation
  Future<void> _startRecommendation() async {
    // Show loading animation
    add(MainPageValueChanged(isLoading: true));

    // Test delay when using mock service
    //await Future.delayed(const Duration(seconds: 2));

    // Get playlist from Quack API
    QuackServiceResponse<GetPlaylistResponse> getPlaylistResponse =
        await _getPlaylist();
    // If not success
    if (!getPlaylistResponse.isSuccess) {
      GeneralUtil.showSnackBar(
          context: context, message: "Could not get a playlist");
      add(MainPageValueChanged(isLoading: false));
      return;
    }

    // Play the first track
    await _playTrack(getPlaylistResponse.quackResponse!.result!.tracks!.first);
    // Show playlist
    add(PlaylistReceived(playList: getPlaylistResponse.quackResponse!.result!));
    // Remove loading animation and start recommendation animation
    add(MainPageValueChanged(isLoading: false, isRecommendationStarted: true));
  }

  //endregion

  //region Startup

  /// Get values when first showing the page
  Future<bool> getValues() async {
    if (!(await _connectToSpotifyRemote())) {
      return false;
    }

    //await _getPlaylist();

    return true;
  }

//endregion

//endregion

}
