import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/history/history_page_events_states.dart';
import '../../helpers/permission_helper.dart';
import '../history_playlist/history_playlist_page_ui.dart';

class HistoryPageBloc extends Bloc<HistoryPageEvent, HistoryPageState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  /// A [BuildContext] set in the constructor, in order to access UI functionality
  /// such as localization and navigation
  late BuildContext context;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  HistoryPageBloc({required this.context})
      : super(HistoryPageState(
            playlists: AppValuesHelper.getInstance().getPlaylists())) {
    /// ButtonPressed
    on<ButtonPressed>((event, emit) async {
      switch (event.buttonEvent) {

        /// Back
        case HistoryButtonEvent.back:
          Navigator.of(context).pop(null);
          break;

        /// Open with Spotify
        case HistoryButtonEvent.openWithSpotify:
          // TODO: Handle this case.
          break;
      }
    });

    /// After selecting a playlist in history page,
    /// show dialog of history playlist screen with selected playlist
    on<PlaylistSelected>((event, emit) async {
      showDialog(
          context: context,
          builder: (context) {
            return HistoryPlaylistPage(playlist: event.playlist);
          });
    });
  }

//endregion

}
