import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

import '../../../helpers/permission_helper.dart';
import 'history_playlist_page_events_states.dart';

class HistoryPlaylistPageBloc
    extends Bloc<HistoryPlaylistPageEvent, HistoryPlaylistPageState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  /// A [BuildContext] set in the constructor, in order to access UI functionality
  /// such as localization and navigation
  late BuildContext context;

  /// A [QuackPlaylist] set in the constructor.
  final QuackPlaylist playlist;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  HistoryPlaylistPageBloc({required this.context, required this.playlist})
      : super(HistoryPlaylistPageState(playlist: playlist)) {
    /// ButtonPressed
    on<ButtonPressed>((event, emit) async {
      switch (event.buttonEvent) {

        /// Back
        case HistoryPlaylistButtonEvent.back:
          Navigator.of(context).pop(null);
          break;
      }
    });
  }
//endregion

}
