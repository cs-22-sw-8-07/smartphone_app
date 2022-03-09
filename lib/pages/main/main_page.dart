import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:spotify_sdk/models/connection_status.dart';
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
  Image? userImage;

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  void initState() {
    super.initState();

    userImage = Image.network(
        AppValuesHelper.getInstance().getString(AppValuesKey.userImageUrl) ??
            "");

    playlistAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    startStopRecommendationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    //startStopRecommendationController.repeat(reverse: true);

    pulseAnimation =
        Tween(begin: 0.0, end: 10.0).animate(startStopRecommendationController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(userImage!.image, context);
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

    playlistSizeAnimation ??=
        Tween<double>(begin: values.mainPageOverlayHeight, end: playlistHeight)
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
                                          decoration: const BoxDecoration(
                                              gradient:
                                                  custom_colors.blackGradient),
                                          child: Column(
                                            children: [
                                              Row(children: [
                                                Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 20,
                                                            top: 20,
                                                            right: 10,
                                                            bottom: 20),
                                                    width: 60,
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    30)),
                                                        child: userImage))
                                              ]),
                                              Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20,
                                                          right: 20,
                                                          bottom: 20),
                                                  child: CustomLabel(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              0),
                                                      alignmentGeometry:
                                                          Alignment.topLeft,
                                                      fontSize: 16,
                                                      textColor: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      title: AppValuesHelper
                                                              .getInstance()
                                                          .getString(AppValuesKey
                                                              .displayName))),
                                              const Image(
                                                  fit: BoxFit.fitWidth,
                                                  image: AssetImage(
                                                      "assets/locations.png"))
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
    return StreamBuilder<PlayerState>(
        stream: bloc.getPlayerState(),
        builder: (context, snapshot) {
          PlayerState? playerState = snapshot.data;
          bloc.add(SpotifyPlayerStateChanged(playerState: snapshot.data));

          return BlocBuilder<MainPageBloc, MainPageState>(
            builder: (context, state) {
              return Stack(
                children: [
                  Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: ExactAssetImage(
                                values.beachBackground,
                              ))),
                      child: ClipRect(
                        child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              color: Colors.white.withOpacity(0.4),
                              child: _getMainContent(bloc, state),
                            )),
                      )),
                  if (playerState != null)
                    _getOverlayContent(bloc, state, playerState),
                ],
              );
            },
          );
        });
  }

  Widget _getOverlayContent(
      MainPageBloc bloc, MainPageState state, PlayerState? playerState) {
    var overlayContent = state.isPlaylistShown!
        ? _getPlaylist(state, playerState)
        : _getTrack(state, playerState);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
            fontWeight: FontWeight.bold,
            height: 30,
            icon: Icon(
              state.isPlaylistShown! ? Icons.expand_more : Icons.expand_less,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {
              bloc.add(const ButtonPressed(
                  buttonEvent: MainButtonEvent.resizePlaylist));
              bloc.state.isPlaylistShown!
                  ? playlistAnimationController.reverse()
                  : playlistAnimationController.forward();
            },
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            margin: const EdgeInsets.all(0),
            textColor: custom_colors.black,
            pressedBackground: custom_colors.blackGradient,
            defaultBackground: custom_colors.blackGradient),
        AnimatedBuilder(
            animation: playlistAnimationController,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                    color: custom_colors.black,
                    border: Border.all(color: custom_colors.black, width: 0)),
                height: playlistSizeAnimation!.value,
                child: AnimatedSwitcher(
                  child: overlayContent,
                  duration: const Duration(milliseconds: 200),
                ),
              );
            })
      ],
    );
  }

  Widget _getMainContent(MainPageBloc bloc, MainPageState state) {
    return Container(
        margin:
            const EdgeInsets.only(bottom: values.mainPageOverlayHeight + 30),
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
            const SizedBox(
              height: 40,
            ),
            Container(
              height: 40,
              decoration: const BoxDecoration(
                  color: custom_colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: CustomLabel(
                isWrapping: true,
                fontSize: 20,
                title: "Beach",
                fontWeight: FontWeight.bold,
                textColor: Colors.white,
                alignmentGeometry: Alignment.center,
                padding: const EdgeInsets.only(
                    left: 20, top: 7, bottom: 10, right: 20),
                margin: const EdgeInsets.all(0),
              ),
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
              fontWeight: FontWeight.w600,
              alignmentGeometry: Alignment.center,
              padding: const EdgeInsets.only(
                  left: 30, top: 10, bottom: 0, right: 30),
              margin: const EdgeInsets.only(top: 30, bottom: 10),
            ),
            CustomButton(
                fontWeight: FontWeight.w900,
                margin: const EdgeInsets.only(left: 30, right: 30),
                borderRadius: const BorderRadius.all(Radius.circular(55 / 2)),
                text: "None selected",
                onPressed: () {},
                textColor: Colors.white,
                pressedBackground: custom_colors.blackPressedGradient,
                defaultBackground: custom_colors.blackGradient),
            Expanded(child: Container()),
          ],
        ));
  }

  Widget _getTrack(MainPageState state, PlayerState? playerState) {
    Track? track = playerState!.track;

    if (track == null) {
      // TODO: Add design for when no track is being played
      return Container();
    }

    String imageUriString = "";
    try {
      imageUriString =
          "https://i.scdn.co/image/" + track.imageUri.raw.split(":")[2];
      // ignore: empty_catches
    } on Exception {}

    return Container(
      decoration: BoxDecoration(
          color: custom_colors.black,
          border: Border.all(width: 0, color: custom_colors.black)),
      height: values.mainPageOverlayHeight,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 0, color: custom_colors.black)),
            margin: const EdgeInsets.all(0),
            width: values.mainPageOverlayHeight,
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                child: Image.network(imageUriString)), //
          ),
          Expanded(
              child: ClipRect(
                  child: Dismissible(
                      dismissThresholds: const {
                DismissDirection.startToEnd: 0.2,
                DismissDirection.endToStart: 0.2,
              },
                      background: const Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: values.mainPageOverlayHeight / 2,
                      ),
                      secondaryBackground: const Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: values.mainPageOverlayHeight / 2,
                      ),
                      onDismissed: (direction) {
                        // ignore: missing_enum_constant_in_switch
                        switch (direction) {
                          // Left -> Next
                          case DismissDirection.endToStart:
                            bloc.add(const TouchEvent(
                                touchEvent: MainTouchEvent.goToNextTrack));
                            break;
                          // Right -> Previous
                          case DismissDirection.startToEnd:
                            bloc.add(const TouchEvent(
                                touchEvent: MainTouchEvent.goToPreviousTrack));
                            break;
                        }
                      },
                      key: UniqueKey(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomLabel(
                            height: values.mainPageOverlayHeight / 2,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            title: track.name,
                            textColor: Colors.white,
                            alignmentGeometry: Alignment.bottomLeft,
                            padding: const EdgeInsets.only(
                                left: 0, top: 0, bottom: 5, right: 0),
                            margin: const EdgeInsets.all(0),
                          ),
                          CustomLabel(
                            alignmentGeometry: Alignment.topLeft,
                            height: values.mainPageOverlayHeight / 2,
                            fontSize: 14,
                            margin: const EdgeInsets.all(0),
                            padding: const EdgeInsets.only(
                                left: 0, top: 5, bottom: 0, right: 0),
                            title: track.artist.name,
                            textColor: custom_colors.darkGrey,
                          )
                        ],
                      )))),
          Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 0, color: custom_colors.black)),
            width: values.mainPageOverlayHeight,
            padding: const EdgeInsets.all(10),
            child: Center(
                child: CustomButton(
                    fontWeight: FontWeight.bold,
                    height: 50,
                    width: 50,
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    icon: Icon(
                      playerState.isPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                      size: values.mainPageOverlayHeight / 2,
                    ),
                    onPressed: () => bloc.add(const ButtonPressed(
                        buttonEvent: MainButtonEvent.resumePausePlayer)),
                    textColor: custom_colors.black,
                    pressedBackground:
                        custom_colors.backButtonGradientPressedDefault,
                    defaultBackground: custom_colors.transparentGradient)),
          ),
        ],
      ),
    );
  }

  Widget _getPlaylist(MainPageState state, PlayerState? playerState) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return _getTrack(state, playerState);
      },
    );
  }

//endregion
}
