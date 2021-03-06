// ignore: must_be_immutable
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/utilities/general_util.dart';

import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:smartphone_app/widgets/custom_list_tile.dart';

import '../../localization/localization_helper.dart';
import 'history_page_events_states.dart';
import 'history_page_bloc.dart';

// ignore: must_be_immutable
class HistoryPage extends StatelessWidget {
  late HistoryPageBloc bloc;

  HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocalizationHelper.init(context: context);
    // Create bloc
    bloc = HistoryPageBloc(context: context);

    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: BlocProvider(
            create: (_) => bloc,
            child: Container(
                color: custom_colors.appSafeAreaColor,
                child: SafeArea(
                    child: Container(
                        constraints: const BoxConstraints.expand(),
                        decoration: const BoxDecoration(),
                        child: BlocBuilder<HistoryPageBloc, HistoryPageState>(
                          builder: (context, state) {
                            return Scaffold(
                              backgroundColor: Colors.white,
                              appBar: CustomAppBar(
                                title: AppLocalizations.of(context)!.history,
                                titleColor: custom_colors.darkBlue,
                                background: custom_colors.transparentGradient,
                                button1Icon: const Icon(
                                  Icons.clear_outlined,
                                  color: custom_colors.darkBlue,
                                  size: 30,
                                ),
                                onButton1Pressed: () => bloc.add(
                                    const ButtonPressed(
                                        buttonEvent: HistoryButtonEvent.back)),
                                appBarLeftButton: AppBarLeftButton.none,
                              ),
                              body: _getContent(context, bloc, state),
                            );
                          },
                        ))))));
  }

  /// Builds the content of the page. It is called directly in the [build]
  /// method
  Widget _getContent(
      BuildContext context, HistoryPageBloc bloc, HistoryPageState state) {
    return ClipRect(
        child: Container(
            constraints: const BoxConstraints.expand(),
            child: Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Expanded(child: _getHistory(state, context, bloc)),
                  ],
                ))));
  }

  /// Creates the list, where each item is built through [_getPlaylist]
  Widget _getHistory(
      HistoryPageState state, BuildContext context, HistoryPageBloc bloc) {
    return ListView.builder(
      itemCount: state.playlists!.length,
      itemBuilder: (context, index) =>
          _getPlaylist(state.playlists![index], context, bloc),
    );
  }

  /// Creates a card with for a given [playlist]. It contains an image for
  /// [quackLocationType], along side the date it was saved and a Spotify button
  Card _getPlaylist(
      QuackPlaylist playlist, BuildContext context, HistoryPageBloc bloc) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(values.borderRadius)),
      child: CustomListTile(
          defaultBackground: custom_colors.appButtonGradient,
          pressedBackground: custom_colors.appButtonGradient,
          widget: ListTile(
            contentPadding: const EdgeInsets.only(
                left: values.padding - 1, right: values.padding),
            leading: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Image.asset(LocalizationHelper.getInstance()
                    .getQuackLocationTypeSmallImagePath(
                        playlist.quackLocationType!))),
            title: Padding(
                padding: const EdgeInsets.only(bottom: values.padding),
                child: Text(
                  LocalizationHelper.getInstance()
                          .getLocalizedQuackLocationType(
                              context, playlist.quackLocationType!) +
                      ", " +
                      playlist.tracks!.length.toString() +
                      " " +
                      AppLocalizations.of(context)!.songs,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                )),
            subtitle: Text(
              playlist.saveDate == null
                  ? "-"
                  : playlist.saveDate!.nowNoSecondsAsString(),
              style: const TextStyle(color: custom_colors.darkGrey),
            ),
            trailing: GestureDetector(
              child: const Image(
                  width: 45,
                  height: 45,
                  color: Colors.white,
                  image: AssetImage(
                    values.spotifyWhiteIcon,
                  )),
              onTap: () {
                if (kDebugMode) {
                  print("Not functionality");
                }
              },
            ),
          ),
          onPressed: () {
            bloc.add(PlaylistSelected(playlist: playlist));
          }),
    );
  }
}
