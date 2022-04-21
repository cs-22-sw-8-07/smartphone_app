// ignore: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_button.dart';

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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        child: BlocBuilder<HistoryPlaylistBloc,
                            HistoryPlaylistState>(
                          builder: (context, state) {
                            return Scaffold(
                              backgroundColor: custom_colors.darkBlue,
                              body: _getContent(context, bloc, state, playlist),
                            );
                          },
                        ))))));
  }
}

Widget _getContent(BuildContext context, HistoryPlaylistBloc bloc,
    HistoryPlaylistState state, QuackPlaylist playlist) {
  return Container(
      constraints: const BoxConstraints.expand(),
      child: Container(
        width: 2,
        padding: const EdgeInsets.only(top: 10),
        child: _createPlaylistContent(playlist, context, bloc),
      ));
}

Widget _addTrack(QuackTrack? quackTrack) {
  return ListTile(
      dense: true,
      isThreeLine: false,
      textColor: Colors.white,
      leading: ClipRRect(
        child: Image.network(
          quackTrack!.imageUrl!,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      title: Text(
        quackTrack.name!,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(quackTrack.artist!));
}

Widget _createPlaylistContent(
    QuackPlaylist playlist, BuildContext context, HistoryPlaylistBloc bloc) {
  if (playlist.tracks == null) {
    return Container();
  } else {
    List<QuackTrack> tracks = playlist.tracks!;
    List<Widget> trackElements = [];

    for (QuackTrack track in tracks) {
      trackElements.add(_addTrack(track));
    }
    return Stack(children: [
      SizedBox(
          height: MediaQuery.of(context).size.height - 190,
          width: double.infinity,
          child: RawScrollbar(
              isAlwaysShown: true,
              thickness: 4,
              thumbColor: Colors.white,
              child: ListView.builder(
                  itemCount: trackElements.length,
                  itemBuilder: (context, index) {
                    return Container(
                        margin: const EdgeInsets.all(0),
                        child: trackElements[index]);
                  }))),
      Align(
          alignment: AlignmentDirectional.bottomCenter,
          child: CustomButton(
            onPressed: () => bloc.add(const ButtonPressed(
                buttonEvent: HistoryPlaylistButtonEvent.back)),
            text: AppLocalizations.of(context)!.close,
            fontWeight: FontWeight.bold,
            borderRadius: const BorderRadius.all(
                Radius.circular(values.buttonHeight / 2)),
            fontSize: 20,
            textColor: Colors.black,
            defaultBackground: custom_colors.whiteGradient,
            pressedBackground: custom_colors.greyGradient,
            margin: const EdgeInsets.only(
                left: values.padding,
                right: values.padding,
                bottom: values.padding),
          ))
    ]);
  }
}
