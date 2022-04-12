// ignore: must_be_immutable
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:smartphone_app/widgets/custom_text_field.dart';

import 'history_page_bloc.dart';
import 'history_page_events_states.dart';

// ignore: must_be_immutable
class HistoryPage extends StatelessWidget {
  late HistoryPageBloc bloc;

  HistoryPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                                title: AppLocalizations.of(context)!.settings,
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
}

Widget _getContent(
    BuildContext context, HistoryPageBloc bloc, HistoryPageState state) {
  return ClipRect(
      child: Container(
          constraints: const BoxConstraints.expand(),
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                children: [
                                  Card(
                                      margin: const EdgeInsets.only(
                                          left: values.padding,
                                          right: values.padding),
                                      child: Column()),
                                  const Card(
                                    margin: EdgeInsets.only(
                                        left: values.padding,
                                        right: values.padding),
                                  ),
                                ],
                              ))),
                      // 'Save' button
                    ],
                  )))));
}
