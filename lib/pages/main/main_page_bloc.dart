import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/localization/localization_helper.dart';
import 'package:smartphone_app/pages/login/login_page_ui.dart';
import 'package:smartphone_app/pages/main/main_page_events_states.dart';
import 'package:smartphone_app/services/quack_location_service/service/quack_location_service.dart';
import 'package:smartphone_app/widgets/question_dialog.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

// ignore: unnecessary_import, implementation_imports

import '../../helpers/key_helper.dart';
import '../../helpers/position_helper/position_helper.dart';
import '../../services/webservices/quack/models/quack_classes.dart';
import '../../services/webservices/quack/services/quack_service.dart';
import '../../services/webservices/spotify/services/spotify_service.dart';
import '../../utilities/general_util.dart';
import '../settings/settings_page_ui.dart';
import '../history/history_page_ui.dart';

class MainPageBloc extends Bloc<MainPageEvent, MainPageState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  /// [_gettingLocationType] is a flag used to allow only one instance call to
  /// QuackLocationService at a time
  bool _gettingLocationType = false;

  /// A [BuildContext] set in the constructor, in order to access UI functionality
  /// such as localization and navigation
  late BuildContext context;

  /// The current [positionHelper] set for the BLoC
  PositionHelper positionHelper;

  /// Stream subscription to the [positionHelper] in order to receive positions
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
            isLocationListShown: false,
            isLoading: false,
            quackLocationType: QuackLocationType.unknown)) {
    LocalizationHelper.init(context: context);

    /// ButtonPressed
    on<ButtonPressed>((event, emit) async {
      switch (event.buttonEvent) {

        /// Start/Stop recommendation
        case MainButtonEvent.startStopRecommendation:
          // If the playlist is null start the recommendation by loading a
          // playlist
          if (state.playlist == null) {
            await _startRecommendation();
          }
          // The playlist is not null, and now this button acts as a
          // resume/pause button
          else {
            await _resumePausePlayer();
          }
          break;

        /// See previous recommendations
        case MainButtonEvent.seeHistory:
          GeneralUtil.showPageAsDialog(context, HistoryPage());
          break;

        /// Go to settings
        case MainButtonEvent.goToSettings:
          // Go to the settings page
          GeneralUtil.showPageAsDialog(context, SettingsPage());
          break;

        /// Log out
        case MainButtonEvent.logOut:
          // Delete the access token
          AppValuesHelper.getInstance()
              .saveString(AppValuesKey.accessToken, "");
          // Go to the login page
          GeneralUtil.goToPage(context, const LoginPage());
          break;

        /// View playlist
        case MainButtonEvent.viewPlaylist:
          // Set the isPlaylistShown flag negated
          emit(state.copyWith(isPlaylistShown: !state.isPlaylistShown!));
          break;

        /// Resume/pause player
        case MainButtonEvent.resumePausePlayer:
          // The current player state is null, do nothing
          if (state.playerState == null) {
            return;
          }
          // Do resume/pause actions
          await _resumePausePlayer();
          break;

        /// Lock/Unlock QuackLocationType
        case MainButtonEvent.lockUnlockQuackLocationType:
          String message = "";
          bool getNewPlaylist = false;

          // QuackLocationType is equal to 'Unknown'
          if (state.quackLocationType == QuackLocationType.unknown) {
            // Show message to the user
            GeneralUtil.showSnackBar(
                context: context,
                message: AppLocalizations.of(context)!
                    .you_cannot_lock_the_location_type_unknown);
            return;
          }
          // QuackLocationType is not locked and the user has not selected a
          // QuackLocationType
          else if (state.lockedQuackLocationType == null) {
            // Set LockedQuackLocationType to QuackLocationType
            emit(state.copyWith(
                lockedQuackLocationType: state.quackLocationType));
            message = AppLocalizations.of(context)!.locked_location;
          } else {
            // Check if the QuackLocationType will change when unlocked.
            // If it changes a new playlist will be loaded
            getNewPlaylist =
                state.quackLocationType != state.lockedQuackLocationType;
            // Set LockedQuackLocationType to null
            var newState = state.copyWith();
            newState.lockedQuackLocationType = null;
            emit(newState);
            message = AppLocalizations.of(context)!.unlocked_location;
          }

          // Show message to the user
          GeneralUtil.showSnackBar(context: context, message: message);

          // If the flag is set, start the recommendation again
          if (getNewPlaylist) {
            await _startRecommendation();
          }
          break;

        /// Select manual location
        case MainButtonEvent.selectManualLocation:
          // Set the IsLocationListShown flag negated
          emit(
              state.copyWith(isLocationListShown: !state.isLocationListShown!));
          break;

        /// Refresh playlist
        case MainButtonEvent.refreshPlaylist:
          // Ask the user if there sure they want to refresh
          var reply = await QuestionDialog.getInstance().show(
              context: context,
              question: AppLocalizations.of(context)!
                  .are_you_sure_you_want_to_refresh_the_playlist);
          // If not yes, do nothing
          if (reply != DialogQuestionResponse.yes) {
            return;
          }
          // Start recommendation
          await _startRecommendation();
          break;

        /// Append to playlist
        case MainButtonEvent.appendToPlaylist:
          // Append to existing playlist
          await _appendToExistingPlaylist();
          break;

        /// Back
        case MainButtonEvent.back:
          if (state.isPlaylistShown!) {
            emit(state.copyWith(isPlaylistShown: false));
          }
          break;
      }
    });

    /// SpotifyPlayerStateChanged
    on<SpotifyPlayerStateChanged>(((event, emit) async {
      if (kDebugMode) {
        print("Player state changed");
      }

      // The current player state is null or the player state in the event is null
      if (state.playerState == null || event.playerState == null) {
        // Update to event player state
        var newState = state.copyWith();
        newState.playerState = event.playerState;
        emit(newState);
        return;
      }

      // Get track from current player state
      QuackTrack? trackFromCurrentPlayerState =
          QuackTrack.trackToQuackTrack(state.playerState!.track);
      // Get track from event player state
      QuackTrack? trackFromNewPlayerState =
          QuackTrack.trackToQuackTrack(event.playerState!.track);

      // HasJustPerformedAction is set or
      // Track from current player state is the same as the one in the track
      // from the event player state or
      // The current track in the state is not null and the track in the event
      // player state is not null and current track in the state is equal to the
      // track in the event player state
      if (state.hasJustPerformedAction! ||
          trackFromNewPlayerState == trackFromCurrentPlayerState ||
          (state.currentTrack != null &&
              trackFromNewPlayerState != null &&
              trackFromNewPlayerState.id == state.currentTrack!.id)) {
        // Update to event player state and remove HasJustPerformedAction flag
        emit(state.copyWith(
            playerState: event.playerState, hasJustPerformedAction: false));
      } else {
        // Playlist is null or
        // Track from the current player state is null
        if (state.playlist == null || trackFromCurrentPlayerState == null) {
          // Update to event player state
          emit(state.copyWith(playerState: event.playerState));
          return;
        }

        // Current track in the state is not null
        if (state.currentTrack != null) {
          // The current track in the state is part of the current playlist
          if (state.playlist!.tracks!.contains(state.currentTrack)) {
            // Get next track
            var nextTrack = getNextTrack(state.currentTrack!);
            // The current track in the state is the last in the playlist,
            // which means there is no next track
            if (nextTrack == null) {
              return;
            }
            // Play next track
            await _playTrack(nextTrack);
            // The next track is the last in the playlist
            if (nextTrack == state.playlist!.tracks!.last) {
              // Add new tracks to the playlist
              await _appendToExistingPlaylist();
            }
          }
          // The current track in the state is not part of the playlist,
          // therefore play the first song in the playlist
          else {
            await _playTrack(state.playlist!.tracks!.first);
          }
        }
        // Current track in the state is null
        else {
          // Update to event player state
          emit(state.copyWith(playerState: event.playerState));
        }
      }
    }));

    /// TouchEvent
    on<TouchEvent>((event, emit) async {
      if (state.playlist != null && state.currentTrack != null) {
        switch (event.touchEvent) {

          /// Go to next track
          case MainTouchEvent.goToNextTrack:
            {
              // Get the next track in the playlist
              var nextTrack = getNextTrack(state.currentTrack!);
              // The current track is the last in the playlist and there is no
              // next track, so do nothing
              if (nextTrack == null) {
                return;
              }
              // Play the next track
              await _playTrack(nextTrack);
              // The next track is the last in the playlist
              if (nextTrack == state.playlist!.tracks!.last) {
                // Append new tracks to the playlist
                await _appendToExistingPlaylist();
              }
              break;
            }

          /// Go to previous track
          case MainTouchEvent.goToPreviousTrack:
            {
              // Get the previous track in the playlist
              QuackTrack? previousTrack = getPreviousTrack(state.currentTrack!);
              // The current track is the first in the playlist and there is no
              // previous track, so play the current track from the beginning
              if (previousTrack == null) {
                await _playTrack(state.currentTrack!);
              } else {
                // Play the previous track
                await _playTrack(previousTrack);
              }
              break;
            }
        }
      }
    });

    /// PlaylistReceived
    on<PlaylistReceived>((event, emit) {
      var newState = state.copyWith(
          updatedItemHashCode:
              event.playList == null ? 0 : event.playList.hashCode);
      newState.playlist = event.playList;
      emit(newState);
    });

    /// TrackSelected
    on<TrackSelected>((event, emit) async {
      // Play the selected track
      SpotifySdkResponse response = await _playTrack(event.quackTrack);
      if (!response.isSuccess) {
        GeneralUtil.showToast(response.errorMessage);
        return;
      }
      // If the last track is selected append additional tracks to the
      // current playlist
      if (event.quackTrack == state.playlist!.tracks!.last) {
        await _appendToExistingPlaylist();
      }
    });

    /// LocationSelected
    on<LocationSelected>((event, emit) async {
      bool getNewPlaylist = false;
      // Set IsLocationListShown to false and set LockedQuackLocationType to the
      // one in the event
      var newState = state.copyWith(
        isLocationListShown: false,
      );
      // If QuackLocationType in the event is and the QuackLocationType in the
      // state is 'Unknown' then remove the playlist and the current track
      if (event.quackLocationType == null &&
          state.quackLocationType == QuackLocationType.unknown) {
        newState.playlist = null;
        newState.currentTrack = null;
        // Stop playing the current track
        if (state.playerState != null && !state.playerState!.isPaused) {
          await _resumePausePlayer();
        }
      } else {
        // Set flag if:
        // QuackLocationType in the event is null and LockedQuackLocationType is
        // not null and QuackLocationType is not equal to
        // LockedQuackLocationType
        // or
        // QuackLocationType in the event is not null and
        // LockedQuackLocationType is null && QuackLocationType is not equal
        // QuackLocationType in the event or
        // LockedQuackLocationType is not null and LockedQuackLocationType is
        // not equal QuackLocationType in the event
        getNewPlaylist = (event.quackLocationType == null &&
                state.lockedQuackLocationType != null &&
                state.quackLocationType != state.lockedQuackLocationType) ||
            (event.quackLocationType != null &&
                    (state.lockedQuackLocationType == null &&
                        state.quackLocationType != event.quackLocationType) ||
                (state.lockedQuackLocationType != null &&
                    state.lockedQuackLocationType != event.quackLocationType));
      }
      // Set LockedQuackLocationType
      newState.lockedQuackLocationType = event.quackLocationType;
      // Update the state
      emit(newState);
      // If the flag is set, start new recommendation
      if (getNewPlaylist) {
        await _startRecommendation();
      }
    });

    /// MainPageValueChanged
    on<MainPageValueChanged>((event, emit) {
      if (kDebugMode) {
        if (event.quackLocationType != null) {
          print("QLT state change");
        }
      }

      // Update the values in the state to the ones from the event
      var newState = state.copyWith(
          quackLocationType: event.quackLocationType ?? state.quackLocationType,
          isLoading: event.isLoading ?? state.isLoading);
      // The current track is set here to allow null values
      newState.currentTrack = event.currentTrack ?? state.currentTrack;
      emit(newState);
    });

    /// HasJustPerformedSpotifyPlayerAction
    on<HasPerformedSpotifyPlayerAction>((event, emit) {
      // Set the flag HasJustPerformedAction to true
      emit(state.copyWith(hasJustPerformedAction: true));
    });

    // The Spotify player connection status
    _subscribeToConnectionStatus();
    // The stream that receives positions from the PositionHelper
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
    positionStreamSubscription =
        positionHelper.getPositionStream().listen((position) async {
      await positionReceived(position);
    });
  }

  /// Method used to set the [position] in QuacklocationService which updates
  /// the QuackLocationType accordingly
  Future<void> positionReceived(Position? position) async {
    // Write position to terminal
    if (kDebugMode) {
      print(position != null
          ? (position.latitude.toString().replaceAll(",", ".") +
              ", " +
              position.longitude.toString().replaceAll(",", "."))
          : "Unknown");
    }

    // Position is not null and the flag _gettingLocationType is not set
    if (position != null && !_gettingLocationType) {
      // Set flag
      _gettingLocationType = true;
      // Get QuackLocationType based on position
      QuackLocationType? quackLocationType =
          await QuackLocationService.getInstance()
              .getQuackLocationType(position);

      // Write QuackLocationType to terminal
      if (kDebugMode) {
        print("QuackLocationType: " +
            (quackLocationType == null
                ? "null"
                : LocalizationHelper.getInstance()
                    .getLocalizedQuackLocationType(
                        context, quackLocationType)));
      }

      if (quackLocationType != null) {
        // If LockedQuackLocationType is null and
        // the playlist is not null and
        // the new QuackLocationType is not equal to the current QuackLocationType
        if (state.lockedQuackLocationType == null &&
            state.playlist != null &&
            state.quackLocationType != quackLocationType) {
          // Set QuackLocationType
          add(MainPageValueChanged(quackLocationType: quackLocationType));
          // Get playlist from Quack API
          QuackServiceResponse<GetPlaylistResponse> response =
              await _getPlaylist(showLoadingBefore: true);
          // Check for success
          if (!response.isSuccess) {
            return;
          }

          // Save playlist to history
          AppValuesHelper.getInstance()
              .savePlaylist(response.quackResponse!.result!);

          // Show playlist
          add(PlaylistReceived(playList: response.quackResponse!.result!));
          // Remove loading animation
          add(const MainPageValueChanged(isLoading: false));
        } else {
          // Set QuackLocationType
          add(MainPageValueChanged(quackLocationType: quackLocationType));
        }
      }
      // Remove flag
      _gettingLocationType = false;
    }
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

  //endregion

  //region Helper methods

  /// Get next track in the playlist
  /// It is found through the index of the given [track]
  ///
  /// If the [track] is the last in the playlist, null will be returned
  QuackTrack? getNextTrack(QuackTrack track) {
    int index = state.playlist!.tracks!.indexOf(track);
    if (index != -1) {
      int nextIndex = index + 1;
      if (index + 1 <= state.playlist!.tracks!.length - 1) {
        return state.playlist!.tracks![nextIndex];
      }
    }
    return null;
  }

  /// Get previous track in the playlist
  /// It is found through the index of the given [track]
  ///
  /// If the [track] is the first in the playlist, null will be returned
  QuackTrack? getPreviousTrack(QuackTrack track) {
    int index = state.playlist!.tracks!.indexOf(state.currentTrack!);
    if (index != -1) {
      if (index > 0) {
        return state.playlist!.tracks![index - 1];
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

  /// Resume/Pause Spotify player
  Future<void> _resumePausePlayer() async {
    if (state.playerState == null) {
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
    add(const HasPerformedSpotifyPlayerAction());
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
  /// [showLoadingBefore] is used to set the isLoading flag in the state before
  /// getting a playlist from the Quack API
  Future<QuackServiceResponse<GetPlaylistResponse>> _getPlaylist(
      {bool showLoadingBefore = false}) async {
    if (showLoadingBefore) {
      // Show loading animation
      add(const MainPageValueChanged(isLoading: true));
    }

    // Get playlist from Quack API
    QuackServiceResponse<GetPlaylistResponse> getPlaylistResponse =
        await QuackService.getInstance().getPlaylist(
            qlt: state.lockedQuackLocationType == null
                ? state.quackLocationType!
                : state.lockedQuackLocationType!,
            playlists: AppValuesHelper.getInstance().getPlaylists());
    // If response is success then give every track a unique key
    if (getPlaylistResponse.isSuccess) {
      if (kDebugMode) {
        print("Playlist received");
      }
      // Set unique keys for every track in order to support tracks with the
      // same Spotify ID
      for (var track in getPlaylistResponse.quackResponse!.result!.tracks!) {
        track.key = KeyHelper.uniqueKey;
      }
    } else {
      if (kDebugMode) {
        print("Playlist received with errors");
      }
    }

    // Return response
    return getPlaylistResponse;
  }

  /// Append to existing playlist
  Future<void> _appendToExistingPlaylist() async {
    // Get playlist from Quack API
    QuackServiceResponse<GetPlaylistResponse> getPlaylistResponse =
        await _getPlaylist(showLoadingBefore: true);
    // If not success
    if (!getPlaylistResponse.isSuccess) {
      GeneralUtil.showSnackBar(
          context: context,
          message: "${await getPlaylistResponse.errorMessage}");
      add(const MainPageValueChanged(isLoading: false));
      return;
    }

    // Add to existing playlist
    var newPlaylist = state.playlist!.copy();
    newPlaylist.appendPlaylist(getPlaylistResponse.quackResponse!.result!);

    // Save playlist to history
    AppValuesHelper.getInstance().savePlaylist(newPlaylist);

    // Show new playlist
    add(PlaylistReceived(playList: newPlaylist));
    // Remove loading animation and start recommendation animation
    add(const MainPageValueChanged(isLoading: false));
  }

  /// Start recommendation
  Future<void> _startRecommendation() async {
    var qlt = state.lockedQuackLocationType == null
        ? state.quackLocationType!
        : state.lockedQuackLocationType!;

    // Cannot get playlist when the location type is 'Unknown'
    if (qlt == QuackLocationType.unknown) {
      GeneralUtil.showSnackBar(
          context: context,
          message: AppLocalizations.of(context)!
              .cannot_get_playlist_for_location_type_unknown);
      return;
    }

    // Get playlist from Quack API
    QuackServiceResponse<GetPlaylistResponse> getPlaylistResponse =
        await _getPlaylist(showLoadingBefore: true);
    // If not success
    if (!getPlaylistResponse.isSuccess) {
      GeneralUtil.showSnackBar(
          context: context,
          message: "${await getPlaylistResponse.errorMessage}");
      add(const MainPageValueChanged(isLoading: false));
      return;
    }

    // Save playlist to history
    AppValuesHelper.getInstance()
        .savePlaylist(getPlaylistResponse.quackResponse!.result!);

    // Play the first track
    await _playTrack(getPlaylistResponse.quackResponse!.result!.tracks!.first);
    // Show playlist
    add(PlaylistReceived(playList: getPlaylistResponse.quackResponse!.result!));
    // Remove loading animation
    add(const MainPageValueChanged(isLoading: false));
  }

  //endregion

  //region Startup

  /// Get values when first showing the page
  Future<bool> getValues() async {
    if (!(await _connectToSpotifyRemote())) {
      return false;
    }
    return true;
  }

//endregion

//endregion

}
