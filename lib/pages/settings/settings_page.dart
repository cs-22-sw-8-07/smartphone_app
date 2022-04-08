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

import 'settings_page_bloc.dart';
import 'settings_page_events_states.dart';

// ignore: must_be_immutable
class SettingsPage extends StatelessWidget {
  late SettingsBloc bloc;

  SettingsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create bloc
    bloc = SettingsBloc(context: context);

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
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: ExactAssetImage(
                                values.settingsBackground,
                              )),
                        ),
                        child: BlocBuilder<SettingsBloc, SettingsState>(
                          builder: (context, state) {
                            return Scaffold(
                              backgroundColor: Colors.transparent,
                              appBar: CustomAppBar(
                                title: AppLocalizations.of(context)!.settings,
                                titleColor: Colors.white,
                                background: custom_colors.appBarBackground,
                                appBarLeftButton: AppBarLeftButton.close,
                                leftButtonPressed: () => bloc.add(
                                    const ButtonPressed(
                                        buttonEvent: SettingsButtonEvent.back)),
                              ),
                              body: _getContent(context, bloc, state),
                            );
                          },
                        ))))));
  }
}

Widget _getContent(
    BuildContext context, SettingsBloc bloc, SettingsState state) {
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
                                          top: values.padding,
                                          left: values.padding,
                                          right: values.padding),
                                      child: Column()),
                                  Card(
                                      margin: const EdgeInsets.only(
                                          top: values.padding,
                                          left: values.padding,
                                          right: values.padding),
                                      child: Column(
                                        children: [],
                                      )),
                                  CustomButton(
                                    onPressed: () => bloc.add(
                                        const ButtonPressed(
                                            buttonEvent: SettingsButtonEvent
                                                .deleteAccount)),
                                    text: AppLocalizations.of(context)!
                                        .delete_account,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    margin:
                                        const EdgeInsets.all(values.padding),
                                  )
                                ],
                              ))),
                      // 'Save' button
                      CustomButton(
                        onPressed: () => bloc.add(const ButtonPressed(
                            buttonEvent: SettingsButtonEvent.save)),
                        text:
                            AppLocalizations.of(context)!.app_name, // TEMP NAME
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        margin: const EdgeInsets.all(values.padding),
                      )
                    ],
                  )))));
}
