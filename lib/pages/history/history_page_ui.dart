// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/utilities/general_util.dart';

import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:smartphone_app/widgets/custom_button.dart';

import 'history_page_events_states.dart';
import 'history_page_bloc.dart';

// ignore: must_be_immutable
class HistoryPage extends StatelessWidget {
  late HistoryBloc bloc;

  HistoryPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create bloc
    bloc = HistoryBloc(context: context);

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
                        child: BlocBuilder<HistoryBloc, HistoryState>(
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
                                          buttonEvent:
                                              HistoryButtonEvent.back)),
                                  leftButtonPressed: () async => {}),
                              body: _getContent(context, bloc, state),
                            );
                          },
                        ))))));
  }
}

Widget _getContent(BuildContext context, HistoryBloc bloc, HistoryState state) {
  return ClipRect(
      child: Container(
          constraints: const BoxConstraints.expand(),
          child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          child: Column(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        values.borderRadius)),
                                child: ListTile(
                                  tileColor: custom_colors.darkBlue,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(width: 0),
                                    borderRadius: BorderRadius.circular(
                                        values.borderRadius),
                                  ),
                                  leading: const Icon(Icons.broken_image,
                                      size: 50, color: custom_colors.white1),
                                  title: Text(DateTime.now().getDateOnlyAsString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: const Text(
                                    "Forest, 5 Songs",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  trailing: GestureDetector(
                                    child: const Image(
                                        width: 45,
                                        height: 45,
                                        color: Colors.green,
                                        image: AssetImage(
                                          "assets/spotify_icon.png",
                                        )),
                                    onTap: () => {GeneralUtil.showToast("🙄")},
                                  ),
                                ),
                              )
                            ],
                          ))),
                ],
              ))));
}
