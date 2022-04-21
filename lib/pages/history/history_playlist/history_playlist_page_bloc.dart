import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

import '../../../helpers/permission_helper.dart';
import '../../../services/webservices/spotify/models/spotify_classes.dart';
import '../../../services/webservices/spotify/services/spotify_service.dart';
import '../../../utilities/general_util.dart';
import '../../main/main_page_ui.dart';
import 'history_playlist_page_events_states.dart';

class HistoryPlaylistBloc
    extends Bloc<HistoryPlaylistEvent, HistoryPlaylistState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext context;
  final QuackPlaylist playlist;
  late PermissionHelper permissionHelper;
  static const List<PermissionWithService> permissions = [Permission.location];

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  HistoryPlaylistBloc({required this.context, required this.playlist})
      : super(HistoryPlaylistState(playlist: playlist)) {
    // ButtonPressed
    on<ButtonPressed>((event, emit) async {
      switch (event.buttonEvent) {
        case HistoryPlaylistButtonEvent.back:
          Navigator.of(context).pop(null);
          break;
      }
    });
  }
//endregion

  ///
  /// METHODS
  ///
  //region Methods

//endregion
}
