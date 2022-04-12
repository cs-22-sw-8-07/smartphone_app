// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:smartphone_app/widgets/custom_button.dart';

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
                        decoration: const BoxDecoration(),
                        child: BlocBuilder<SettingsBloc, SettingsState>(
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
                                        buttonEvent: SettingsButtonEvent.back)),
                                appBarLeftButton: AppBarLeftButton.none,
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
          child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              CustomButton(
                                onPressed: () => bloc.add(const ButtonPressed(
                                    buttonEvent:
                                        SettingsButtonEvent.deleteAccount)),
                                text: AppLocalizations.of(context)!
                                    .delete_account,
                                icon: const Icon(Icons.delete,
                                    color: Colors.white, size: 35),
                                fontWeight: FontWeight.bold,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(27.5)),
                                fontSize: 20,
                                margin: const EdgeInsets.only(
                                    left: values.padding,
                                    right: values.padding,
                                    bottom: values.buttonPadding),
                              ),
                              CustomButton(
                                onPressed: () => bloc.add(const ButtonPressed(
                                    buttonEvent: SettingsButtonEvent.save)),
                                text: "PLACEHOLDER",
                                icon: const Icon(Icons.broken_image,
                                    color: Colors.white, size: 35),
                                fontWeight: FontWeight.bold,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(27.5)),
                                fontSize: 20,
                                margin: const EdgeInsets.only(
                                    left: values.padding,
                                    right: values.padding,
                                    bottom: values.buttonPadding),
                              ),
                            ],
                          ))),
                ],
              ))));
}
