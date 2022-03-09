import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/models/track.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_drawer_tile.dart';
import 'main_page_bloc.dart';
import 'main_page_events_states.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  ///
  /// VARIABLES
  ///
  //region Variables

  late MainPageBloc bloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late AnimationController playlistAnimationController;
  late AnimationController startStopRecommendationController;
  Animation<double>? playlistSizeAnimation;
  Animation<double>? pulseAnimation;
  late double playlistHeight;

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  void initState() {
    super.initState();

    playlistAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    startStopRecommendationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    //startStopRecommendationController.repeat(reverse: true);

    pulseAnimation =
        Tween(begin: 0.0, end: 10.0).animate(startStopRecommendationController);
  }

  @override
  void dispose() {
    playlistAnimationController.dispose();
    startStopRecommendationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bloc = MainPageBloc(context: context);

    var availableHeight = MediaQuery.of(context).size.height -
        56 -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    playlistHeight = availableHeight - 55 - 100;

    playlistSizeAnimation ??= Tween<double>(begin: 80, end: playlistHeight)
        .animate(playlistAnimationController);

    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: FutureBuilder<bool>(
            future: bloc.getValues(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container(color: Colors.white);
              }
              return BlocProvider(
                  create: (_) => bloc,
                  child: Container(
                      color: custom_colors.appSafeAreaColor,
                      child: SafeArea(
                          child: Scaffold(
                              key: _scaffoldKey,
                              drawer: Drawer(
                                child: Container(
                                    color: Colors.white,
                                    child: ListView(
                                      // Important: Remove any padding from the ListView.
                                      padding: EdgeInsets.zero,
                                      children: [
                                        Container(
                                          color: custom_colors.black,
                                          height: 56,
                                          child: Row(
                                            children: [
                                              CustomButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                height: 44,
                                                width: 44,
                                                margin: const EdgeInsets.only(
                                                    left: 8),
                                                imagePadding:
                                                    const EdgeInsets.all(10),
                                                showBorder: false,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(22)),
                                                defaultBackground: custom_colors
                                                    .transparentGradient,
                                                pressedBackground: custom_colors
                                                    .backButtonGradientPressedDefault,
                                                icon: const Icon(Icons.close,
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                        CustomDrawerTile(
                                          icon: const Icon(
                                            Icons.list_outlined,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            bloc.add(const ButtonPressed(
                                                buttonEvent: MainButtonEvent
                                                    .seeRecommendations));
                                          },
                                          text: AppLocalizations.of(context)!
                                              .recommendations,
                                        ),
                                        Container(
                                          height: 1,
                                          color: custom_colors.black,
                                        ),
                                        CustomDrawerTile(
                                          icon: const Icon(
                                            Icons.settings_outlined,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            bloc.add(const ButtonPressed(
                                                buttonEvent: MainButtonEvent
                                                    .goToSettings));
                                          },
                                          text: AppLocalizations.of(context)!
                                              .settings,
                                        ),
                                        Container(
                                          height: 1,
                                          color: custom_colors.black,
                                        ),
                                        CustomDrawerTile(
                                          icon: const Icon(
                                              Icons.logout_outlined,
                                              color: Colors.black,
                                              size: 30),
                                          text: AppLocalizations.of(context)!
                                              .log_off,
                                          onPressed: () async {
                                            Navigator.pop(context);

                                            bloc.add(const ButtonPressed(
                                                buttonEvent:
                                                    MainButtonEvent.logOff));
                                          },
                                        ),
                                      ],
                                    )),
                              ),
                              body: _getContent(bloc)))));
            }));
  }

  Widget _getContent(MainPageBloc bloc) {
    return BlocBuilder<MainPageBloc, MainPageState>(
      builder: (context, state) {
        var overlayWidget = StreamBuilder<PlayerState>(
            stream: bloc.getPlayerState(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container();
              }

              PlayerState? playerState = snapshot.data;
              if (playerState == null) {
                return Container();
              }

              if (playerState.track == null) {
                return Container();
              }

              return state.isPlaylistShown!
                  ? _getPlaylist(state, playerState)
                  : _getTrack(state, playerState.track!);
            });

        //var overlayWidget =
        //    state.isPlaylistShown! ? _getPlaylist(state) : _getTrack(state);

        return Stack(
          children: [
            Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: ExactAssetImage(
                          values.beachBackground,
                        ))),
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: Colors.white.withOpacity(0.4),
                      child: _getMainContent(bloc, state),
                    ))),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                    fontWeight: FontWeight.bold,
                    height: 40,
                    icon: Icon(
                      state.isPlaylistShown!
                          ? Icons.expand_more
                          : Icons.expand_less,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      bloc.add(const ButtonPressed(
                          buttonEvent: MainButtonEvent.resizePlaylist));
                      bloc.state.isPlaylistShown!
                          ? playlistAnimationController.reverse()
                          : playlistAnimationController.forward();
                    },
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    textColor: custom_colors.black,
                    pressedBackground: custom_colors.blackGradient,
                    defaultBackground: custom_colors.blackGradient,
                    margin: const EdgeInsets.only(top: 100)),
                AnimatedBuilder(
                    animation: playlistAnimationController,
                    builder: (context, _) {
                      return Container(
                        decoration: BoxDecoration(
                            color: custom_colors.black,
                            border: Border.all(width: 0)),
                        height: playlistSizeAnimation!.value,
                        child: AnimatedSwitcher(
                          child: overlayWidget,
                          duration: const Duration(milliseconds: 200),
                        ),
                      );
                    })
              ],
            )
          ],
        );
      },
    );
  }

  Widget _getMainContent(MainPageBloc bloc, MainPageState state) {
    return Container(
        margin: const EdgeInsets.only(bottom: 80 + 55),
        child: Column(
          children: [
            CustomAppBar(
              title: AppLocalizations.of(context)!.app_name,
              titleColor: Colors.black,
              background: custom_colors.appBarBackground,
              appBarLeftButton: AppBarLeftButton.menu,
              leftButtonPressed: () async =>
                  {_scaffoldKey.currentState!.openDrawer()},
            ),
            CustomLabel(
              height: 40,
              fontSize: 14,
              title: "Current scene",
              textColor: Colors.black,
              alignmentGeometry: Alignment.center,
              padding:
                  const EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 0),
              margin: const EdgeInsets.only(top: 20),
            ),
            CustomLabel(
              height: 40,
              fontSize: 20,
              title: "Beach",
              fontWeight: FontWeight.bold,
              textColor: Colors.black,
              alignmentGeometry: Alignment.center,
              padding:
                  const EdgeInsets.only(left: 0, top: 10, bottom: 0, right: 0),
              margin: const EdgeInsets.all(0),
            ),
            Expanded(child: Container()),
            AnimatedBuilder(
              animation: startStopRecommendationController,
              builder: (context, _) {
                return CustomButton(
                    fontWeight: FontWeight.bold,
                    height: 100,
                    width: 100,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    icon: Icon(
                      !state.isRecommendationStarted!
                          ? Icons.play_arrow
                          : Icons.pause,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {
                      bloc.add(const ButtonPressed(
                          buttonEvent:
                              MainButtonEvent.startStopRecommendation));
                      if (!bloc.state.isRecommendationStarted!) {
                        startStopRecommendationController.repeat(reverse: true);
                      } else {
                        startStopRecommendationController.stop();
                        startStopRecommendationController.reset();
                      }
                    },
                    boxShadow: BoxShadow(
                        color: custom_colors.blue,
                        blurRadius: pulseAnimation!.value,
                        spreadRadius: pulseAnimation!.value),
                    pressedBackground: custom_colors.blackPressedGradient,
                    defaultBackground: custom_colors.blackGradient);
              },
            ),
            CustomLabel(
              height: 40,
              fontSize: 16,
              title: "Preference profile",
              textColor: Colors.black,
              alignmentGeometry: Alignment.centerLeft,
              padding: const EdgeInsets.only(
                  left: 30, top: 10, bottom: 0, right: 30),
              margin: const EdgeInsets.all(0),
            ),
            CustomButton(
                fontWeight: FontWeight.bold,
                margin: const EdgeInsets.only(left: 30, right: 30),
                text: "None selected",
                onPressed: () {},
                textColor: Colors.white,
                pressedBackground: custom_colors.blackPressedGradient,
                defaultBackground: custom_colors.blackGradient),
            Expanded(child: Container()),
          ],
        ));
  }

  Widget _getTrack(MainPageState state, Track track) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(width: 0, color: custom_colors.black)),
      height: 80,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 0, color: custom_colors.black)),
            margin: const EdgeInsets.all(0),
            width: 80,
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                child: Image.network(track.imageUri.raw)), //
          ),
          Expanded(
              child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomLabel(
                height: 40,
                fontSize: 14,
                title: track.name,
                textColor: Colors.white,
                alignmentGeometry: Alignment.bottomLeft,
                padding:
                    const EdgeInsets.only(left: 0, top: 0, bottom: 5, right: 0),
                margin: const EdgeInsets.all(0),
              ),
              CustomLabel(
                alignmentGeometry: Alignment.topLeft,
                height: 40,
                fontSize: 14,
                margin: const EdgeInsets.all(0),
                padding:
                    const EdgeInsets.only(left: 0, top: 5, bottom: 0, right: 0),
                title: track.artist.name,
                textColor: custom_colors.darkGrey,
              )
            ],
          )),
          Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 0, color: custom_colors.black)),
            width: 80,
            padding: const EdgeInsets.all(10),
            child: Center(
                child: CustomButton(
                    fontWeight: FontWeight.bold,
                    height: 50,
                    width: 50,
                    icon: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {},
                    textColor: custom_colors.black,
                    pressedBackground: custom_colors.transparentGradient,
                    defaultBackground: custom_colors.transparentGradient)),
          ),
        ],
      ),
    );
  }

  Widget _getPlaylist(MainPageState state, PlayerState playerState) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return _getTrack(state, playerState.track!);
      },
    );
  }

//endregion
}
