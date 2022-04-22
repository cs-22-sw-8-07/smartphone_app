
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/history/history_page_events_states.dart';
import 'package:smartphone_app/pages/history/history_playlist/history_playlist_page_ui.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import '../../helpers/permission_helper.dart';
import '../../utilities/general_util.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext context;
  late PermissionHelper permissionHelper;
  static const List<PermissionWithService> permissions = [Permission.location];

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  HistoryBloc({required this.context})
      : super(HistoryState(
            playlists: AppValuesHelper.getInstance().getPlaylists())) {
    // ButtonPressed
    on<ButtonPressed>((event, emit) async {
      switch (event.buttonEvent) {
        case HistoryButtonEvent.back:
          Navigator.of(context).pop(null);
          break;
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
            return HistoryPlaylistPage(playlist: event.selectedPlaylist);
          });
    });
  }
//endregion

  ///
  /// METHODS
  ///
//region Methods

  void acquireHistory() {
    //TODO: Get the list of previously recommended playlists
  }

//endregion
}
