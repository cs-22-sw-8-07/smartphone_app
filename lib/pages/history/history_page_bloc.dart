import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/history/history_page_events_states.dart';

import '../../helpers/permission_helper.dart';
import '../../services/webservices/spotify/models/spotify_classes.dart';
import '../../services/webservices/spotify/services/spotify_service.dart';
import '../../utilities/general_util.dart';
import '../main/main_page_ui.dart';

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
      : super(const HistoryState()) {
    
    // ButtonPressed
    on<ButtonPressed>((event, emit) async {
      switch (event.buttonEvent) {
        case HistoryButtonEvent.back:
          Navigator.of(context).pop(null);
          break;
        case HistoryButtonEvent.openPlaylist:
          // TODO: Handle this case.
          break;
        case HistoryButtonEvent.openWithSpotify:
          // TODO: Handle this case.
          break;
      }
    });

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
}
