// ignore: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_button.dart';

import '../../../localization/localization_helper.dart';
import '../../../widgets/custom_label.dart';
import '../../../widgets/custom_list_tile.dart';
import 'history_playlist_page_events_states.dart';
import 'history_playlist_page_bloc.dart';

// ignore: must_be_immutable
class HistoryPlaylistPage extends StatelessWidget {
  late HistoryPlaylistPageBloc bloc;
  final QuackPlaylist playlist;

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  HistoryPlaylistPage({Key? key, required this.playlist}) : super(key: key);

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Widget build(BuildContext context) {
    LocalizationHelper.init(context: context);
    // Create bloc
    bloc = HistoryPlaylistPageBloc(context: context, playlist: playlist);

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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        child: BlocBuilder<HistoryPlaylistPageBloc,
                            HistoryPlaylistPageState>(
                          builder: (context, state) {
                            return Scaffold(
                              backgroundColor: custom_colors.darkBlue,
                              body: _getContent(context, bloc, state),
                            );
                          },
                        ))))));
  }

  //endregion

  ///
  /// BUILD METHODS
  ///
//region Build methods

  /// Builds the content of the page. It is called directly in the [build]
  /// method
  Widget _getContent(BuildContext context, HistoryPlaylistPageBloc bloc,
      HistoryPlaylistPageState state) {
    return Container(
        constraints: const BoxConstraints.expand(),
        child: Container(
          width: 2,
          padding: const EdgeInsets.only(top: 10),
          child: _createPlaylistContent(state.playlist!, context, bloc),
        ));
  }

  /// Creates a list tile with the song title, artist & coverart
  Widget _getTrack(QuackTrack? quackTrack) {
    return CustomListTile(
      pressedBackground: custom_colors.transparentGradient,
      defaultBackground: custom_colors.transparentGradient,
      widget: Container(
        decoration: BoxDecoration(
            color: custom_colors.darkBlue,
            border: Border.all(width: 0, color: custom_colors.darkBlue)),
        height: values.mainPageOverlayHeight,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(width: 0, color: custom_colors.darkBlue)),
              margin: const EdgeInsets.all(0),
              width: values.mainPageOverlayHeight,
              padding: const EdgeInsets.all(values.padding),
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  child: Image.network(quackTrack!.imageUrl!)), //
            ),
            Expanded(
                child: ClipRect(
                    child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomLabel(
                  height: values.mainPageOverlayHeight / 2,
                  fontSize: 14,
                  maxLines: 1,
                  softWrap: false,
                  useOverflowReplacement: true,
                  fontWeight: FontWeight.w900,
                  title: quackTrack.name,
                  textColor: Colors.white,
                  alignmentGeometry: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                      left: 0,
                      top: values.padding,
                      bottom: 5,
                      right: values.padding),
                  margin: const EdgeInsets.all(0),
                ),
                CustomLabel(
                  alignmentGeometry: Alignment.centerLeft,
                  height: values.mainPageOverlayHeight / 2,
                  fontSize: 14,
                  maxLines: 1,
                  softWrap: false,
                  useOverflowReplacement: true,
                  margin: const EdgeInsets.all(0),
                  padding: const EdgeInsets.only(
                      left: 0,
                      top: 5,
                      bottom: values.padding,
                      right: values.padding),
                  title: quackTrack.artist,
                  textColor: custom_colors.darkGrey,
                )
              ],
            ))),
          ],
        ),
      ),
      onPressed: () {},
    );
  }

  /// Creates the list of tracks from a given [playlist]
  /// Shows an empty container if the [playlist] has no tracks
  Widget _createPlaylistContent(QuackPlaylist playlist, BuildContext context,
      HistoryPlaylistPageBloc bloc) {
    return Column(children: [
      Expanded(
          child: RawScrollbar(
              isAlwaysShown: true,
              thickness: 4,
              thumbColor: Colors.white,
              child: playlist.tracks == null
                  ? Container()
                  : ListView.builder(
                      itemCount: playlist.tracks!.length,
                      itemBuilder: (context, index) {
                        return Container(
                            margin: const EdgeInsets.all(0),
                            child: _getTrack(playlist.tracks![index]));
                      }))),
      CustomButton(
        onPressed: () => bloc.add(
            const ButtonPressed(buttonEvent: HistoryPlaylistButtonEvent.back)),
        text: AppLocalizations.of(context)!.close,
        fontWeight: FontWeight.bold,
        borderRadius:
            const BorderRadius.all(Radius.circular(values.buttonHeight / 2)),
        fontSize: 20,
        textColor: Colors.black,
        defaultBackground: custom_colors.whiteGradient,
        pressedBackground: custom_colors.greyGradient,
        margin: const EdgeInsets.only(
            left: values.padding,
            right: values.padding,
            bottom: values.padding),
      )
    ]);
  }

//endregion
}
