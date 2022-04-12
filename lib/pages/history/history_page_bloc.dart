import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart' as location;
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/history/history_page_events_states.dart';

import '../../helpers/permission_helper.dart';
import '../../services/webservices/spotify/models/spotify_classes.dart';
import '../../services/webservices/spotify/services/spotify_service.dart';
import '../../utilities/general_util.dart';
import '../main/main_page_ui.dart';

class HistoryPageBloc extends Bloc<HistoryPageEvent, HistoryPageState> {
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

  HistoryPageBloc({required this.context})
      : super(HistoryPageState(permissionState: PermissionState.denied)) {
    /// ButtonPressed
    on<ButtonPressed>((event, emit) async {
      switch (event.buttonEvent) {
        case HistoryButtonEvent.back:
          // TODO: Handle this case.
          break;
        case HistoryButtonEvent.selectedPlaylist:
          // TODO: Handle this case.
          break;
        case HistoryButtonEvent.openInSpotify:
          // TODO: Handle this case.
          break;
      }
    });
  }

//endregion

  ///
  /// METHODS
  ///
//region Methods

  void placeholder() {}

//endregion

}
