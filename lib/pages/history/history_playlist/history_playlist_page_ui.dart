// ignore: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/pages/history/history_page_events_states.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/utilities/general_util.dart';

import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';

import '../../../localization/localization_helper.dart';
import 'history_playlist_page_events_states.dart';
import 'history_playlist_page_bloc.dart';

// ignore: must_be_immutable
class HistoryPlaylistPage extends StatelessWidget {
  late HistoryPlaylistBloc bloc;
  final QuackPlaylist playlist;

  HistoryPlaylistPage({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocalizationHelper.init(context: context);
    // Create bloc
    bloc = HistoryPlaylistBloc(context: context, playlist: playlist);

    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: BlocProvider(
            create: (_) => bloc,
            child: Container(
                margin: const EdgeInsets.all(35),
                color: custom_colors.transparent,
                child: SafeArea(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: BlocBuilder<HistoryPlaylistBloc,
                            HistoryPlaylistState>(
                          builder: (context, state) {
                            return Scaffold(
                              backgroundColor: custom_colors.darkBlue,
                              body: _getContent(context, bloc, state),
                            );
                          },
                        ))))));
  }
}

Widget _getContent(BuildContext context, HistoryPlaylistBloc bloc,
    HistoryPlaylistState state) {
  return ClipRect(
      child: Container(
          constraints: const BoxConstraints.expand(),
          child: Container(
              color: Colors.transparent, child: _createPlaylistContent())));
}

Widget _createPlaylistContent(PlaylistSelected playlist) {
  if (playlist.selectedPlaylist.tracks == null) {
    return Container();
  } else {
    List<QuackTrack> tracks = playlist.selectedPlaylist.tracks!;
    List<Widget> trackElements = [];

    for (QuackTrack track in tracks) {
      trackElements.add();
    }
  }
  Widget _addTrack(QuackTrack? quackTrack) {
    return ListTile(autofocus: false, leading: Text("x"), trailing: Text("x"));
  }
}
