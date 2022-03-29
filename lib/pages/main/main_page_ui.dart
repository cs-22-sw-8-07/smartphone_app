import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/localization/localization_helper.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:smartphone_app/widgets/custom_list_tile.dart';
import 'package:spotify_sdk/models/track.dart';
import 'package:geolocator_android/src/types/foreground_settings.dart';

import '../../helpers/position_helper/udp_position_helper.dart';
import '../../services/webservices/quack/models/quack_classes.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_drawer_tile.dart';
import '../../widgets/custom_play_button.dart';
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
  late double playlistHeight;
  Image? userImage;

  late double availableHeight;
  late double availableWidth;

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
    bloc = MainPageBloc(context: context, positionHelper: UdpPositionHelper(
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            forceLocationManager: true,
            intervalDuration: const Duration(seconds: 10),
            //(Optional) Set foreground notification config to keep the app alive
            //when going to the background
            foregroundNotificationConfig: ForegroundNotificationConfig(
              notificationIcon: const AndroidResource(
                  name: "notification_icon", defType: "drawable"),
              notificationText:
              AppLocalizations.of(context)!.getting_location_in_background,
              notificationTitle: AppLocalizations.of(context)!.app_name,
              enableWakeLock: true,
            )),
        appleSettings: AppleSettings(
          accuracy: LocationAccuracy.high,
          activityType: ActivityType.fitness,
          distanceFilter: 100,
          pauseLocationUpdatesAutomatically: true,
          // Only set to true if our app will be started up in the background.
          showBackgroundLocationIndicator: false,
        )));

    availableWidth = MediaQuery
        .of(context)
        .size
        .width;

    availableHeight = MediaQuery
        .of(context)
        .size
        .height -
        MediaQuery
            .of(context)
            .padding
            .top -
        MediaQuery
            .of(context)
            .padding
            .bottom;

    playlistHeight = availableHeight - values.actionBarHeight;

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
                              drawer: _getDrawer(bloc),
                              body: _getContent(bloc)))));
            }));
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  bool _shouldUpdateQuackLocationType(MainPageState previous,
      MainPageState current) {
    if (previous.quackLocationType == current.quackLocationType &&
        previous.lockedQuackLocationType == null &&
        current.lockedQuackLocationType == null) {
      return false;
    }

    if (previous.lockedQuackLocationType != null &&
        current.lockedQuackLocationType != null &&
        previous.lockedQuackLocationType == current.lockedQuackLocationType) {
      return false;
    }

    return previous.quackLocationType != current.quackLocationType ||
        (current.lockedQuackLocationType != null &&
            current.lockedQuackLocationType != previous.quackLocationType) ||
        (current.lockedQuackLocationType == null &&
            current.quackLocationType != previous.lockedQuackLocationType);
  }

  Widget _getContent(MainPageBloc bloc) {
    return Stack(
      children: [
        _getMainContent(bloc),
        _getOverlayContent(bloc),
      ],
    );
  }

  Widget _getDrawer(MainPageBloc bloc) {
    return Drawer(
      child: Container(
          color: Colors.white,
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              Container(
                decoration: const BoxDecoration(
                    gradient: custom_colors.appButtonGradient),
                child: Column(
                  children: [
                    Row(children: [
                      Container(
                          margin: const EdgeInsets.only(
                              left: 20, top: 20, right: 10, bottom: 20),
                          width: 60,
                          child: ClipRRect(
                              borderRadius:
                              const BorderRadius.all(Radius.circular(30)),
                              child: userImage))
                    ]),
                    Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20),
                        child: CustomLabel(
                            margin: const EdgeInsets.all(0),
                            alignmentGeometry: Alignment.topLeft,
                            fontSize: 16,
                            textColor: Colors.white,
                            fontWeight: FontWeight.w700,
                            title: AppValuesHelper.getInstance()
                                .getString(AppValuesKey.displayName))),
                    const Image(
                        fit: BoxFit.fitWidth,
                        image: AssetImage(values.locationShadowImage))
                  ],
                ),
              ),
              CustomDrawerTile(
                icon: const Icon(
                  Icons.list_outlined,
                  color: custom_colors.darkBlue,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  bloc.add(const ButtonPressed(
                      buttonEvent: MainButtonEvent.seeRecommendations));
                },
                text: AppLocalizations.of(context)!.recommendations,
              ),
              CustomDrawerTile(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: custom_colors.darkBlue,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  bloc.add(const ButtonPressed(
                      buttonEvent: MainButtonEvent.goToSettings));
                },
                text: AppLocalizations.of(context)!.settings,
              ),
              CustomDrawerTile(
                icon: const Icon(Icons.logout_outlined,
                    color: custom_colors.darkBlue, size: 30),
                text: AppLocalizations.of(context)!.log_off,
                onPressed: () async {
                  Navigator.pop(context);

                  bloc.add(
                      const ButtonPressed(buttonEvent: MainButtonEvent.logOff));
                },
              ),
            ],
          )),
    );
  }

  Widget _getOverlayContent(MainPageBloc bloc) {
    return BlocBuilder<MainPageBloc, MainPageState>(builder: (context, state) {
      var overlayContent = state.isPlaylistShown!
          ? _getPlaylist(state)
          : _getCurrentlyPlayingTrack(state);

      var refreshButton = state.isPlaylistShown!
          ? CustomButton(
          fontWeight: FontWeight.bold,
          height: 30,
          width: 30,
          icon: const Icon(
            Icons.refresh_outlined,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {},
          borderRadius: const BorderRadius.all(
            Radius.circular(0),
          ),
          margin: const EdgeInsets.only(
              right: (values.actionBarHeight - 30) / 2),
          textColor: custom_colors.black,
          pressedBackground: custom_colors.backButtonGradientPressedDefault,
          defaultBackground: custom_colors.transparentGradient)
          : Container();

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
              height: state.playlist == null
                  ? 0
                  : (state.isPlaylistShown! ? values.actionBarHeight : 40),
              duration: const Duration(milliseconds: 200),
              child: Stack(
                children: [
                  CustomButton(
                      fontWeight: FontWeight.bold,
                      height: null,
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
                      borderRadius: const BorderRadius.all(
                        Radius.circular(0),
                      ),
                      margin: const EdgeInsets.all(0),
                      textColor: custom_colors.black,
                      pressedBackground: custom_colors.appButtonPressedGradient,
                      defaultBackground: custom_colors.appButtonGradient),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: refreshButton,
                    ),
                  )
                ],
              )),
          AnimatedBuilder(
              animation: playlistAnimationController,
              builder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                      color: custom_colors.darkBlue,
                      border:
                      Border.all(color: custom_colors.darkBlue, width: 0)),
                  height: playlistSizeAnimation!.value,
                  child: AnimatedSwitcher(
                    child: overlayContent,
                    duration: const Duration(milliseconds: 200),
                  ),
                );
              })
        ],
      );
    });
  }

  Widget _getMainContent(MainPageBloc bloc) {
    return Container(
        decoration: const BoxDecoration(color: custom_colors.transparent),
        child: Stack(
          children: [
            BlocBuilder<MainPageBloc, MainPageState>(
                buildWhen: (previous, current) {
                  return _shouldUpdateQuackLocationType(previous, current);
                }, builder: (context, state) {
              return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Image.asset(
                    LocalizationHelper.getInstance()
                        .getQuackLocationTypeImagePath(
                        state.lockedQuackLocationType == null
                            ? state.quackLocationType!
                            : state.lockedQuackLocationType!),
                    fit: BoxFit.fill,
                    height: double.infinity,
                    width: double.infinity,
                    key: UniqueKey(),
                  ));
            }),
            Column(
              children: [
                Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: custom_colors.transparentWhiteGradient,
                          border: Border.all(
                              color: Colors.transparent, width: 0)),
                    ))
              ],
            ),
            Column(
              children: [
                SizedBox(
                    height: values.actionBarHeight,
                    child: Stack(children: [
                      CustomAppBar(
                        background: custom_colors.transparentGradient,
                        appBarLeftButtonIconColor: custom_colors.darkBlue,
                        buttonBackground: custom_colors.whiteGradient,
                        buttonPressedBackground: custom_colors.greyGradient,
                        appBarLeftButton: AppBarLeftButton.menu,
                        leftButtonPressed: () async =>
                        {_scaffoldKey.currentState!.openDrawer()},
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                              onTapUp: (v) =>
                                  bloc.add(const ButtonPressed(
                                      buttonEvent:
                                      MainButtonEvent.selectManualLocation)),
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth: availableWidth / 2),
                                decoration: const BoxDecoration(
                                    gradient: custom_colors.whiteGradient,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(22))),
                                padding: const EdgeInsets.only(
                                    left: 20, top: 0, right: 10),
                                height: 44,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    BlocBuilder<MainPageBloc, MainPageState>(
                                        builder: (context, state) {
                                          return Text(
                                            LocalizationHelper.getInstance()
                                                .getLocalizedQuackLocationType(
                                                context,
                                                state.lockedQuackLocationType ==
                                                    null
                                                    ? state.quackLocationType!
                                                    : state
                                                    .lockedQuackLocationType!),
                                            softWrap: true,
                                            maxLines: 1,
                                            style: GoogleFonts.roboto(
                                                textStyle: const TextStyle(
                                                    color: custom_colors
                                                        .darkBlue,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 20)),
                                          );
                                        }),
                                    Container(
                                        margin: const EdgeInsets.only(left: 5),
                                        child: const Icon(
                                          Icons.expand_more,
                                          size: 30,
                                          color: custom_colors.darkBlue,
                                        ))
                                  ],
                                ),
                              )))
                    ])),
                SizedBox(height: availableHeight * 0.35),
                BlocBuilder<MainPageBloc, MainPageState>(
                    builder: (context, state) {
                      return Container(
                          margin: const EdgeInsets.only(bottom: 30, top: 0),
                          child: Align(
                            alignment: Alignment.center,
                            child: PlayButton(
                                width: 40,
                                height: 40,
                                foreground: Icon(
                                  state.lockedQuackLocationType == null
                                      ? Icons.lock_outline
                                      : Icons.lock_open_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () =>
                                    bloc.add(const ButtonPressed(
                                        buttonEvent: MainButtonEvent
                                            .lockUnlockQuackLocationType)),
                                pressedBackground:
                                custom_colors.appButtonPressedGradient,
                                defaultBackground: custom_colors
                                    .appButtonGradient),
                          ));
                    }),
                BlocBuilder<MainPageBloc, MainPageState>(
                    builder: (context, state) {
                      return SizedBox(
                        child: Row(
                          children: [
                            const Expanded(child: SizedBox()),
                            CustomButton(
                                margin: const EdgeInsets.only(right: 30),
                                height: values.mainPagePlayPauseButtonSize / 2,
                                width: values.mainPagePlayPauseButtonSize / 2,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(
                                        values.mainPagePlayPauseButtonSize /
                                            2 /
                                            2)),
                                icon: const Icon(
                                  Icons.skip_previous,
                                  color: custom_colors.darkBlue,
                                  size: values.mainPagePlayPauseButtonSize / 3,
                                ),
                                onPressed: () =>
                                    bloc.add(const TouchEvent(
                                        touchEvent: MainTouchEvent
                                            .goToPreviousTrack)),
                                pressedBackground: custom_colors.greyGradient,
                                defaultBackground:
                                custom_colors.transparentGradient),
                            AnimatedBuilder(
                              animation: startStopRecommendationController,
                              builder: (context, _) {
                                return PlayButton(
                                  margin:
                                  const EdgeInsets.only(top: 30, bottom: 30),
                                  height: values.mainPagePlayPauseButtonSize,
                                  width: values.mainPagePlayPauseButtonSize,
                                  defaultBackground:
                                  custom_colors.appButtonGradient,
                                  pressedBackground:
                                  custom_colors.appButtonPressedGradient,
                                  isPlaying: state.isRecommendationStarted!,
                                  foreground: state.isLoading!
                                      ? Container(
                                      padding: const EdgeInsets.all(35),
                                      child: const CircularProgressIndicator(
                                          color: Colors.white))
                                      : Icon(
                                      state.isRecommendationStarted!
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40),
                                  onPressed: () =>
                                      bloc.add(const ButtonPressed(
                                          buttonEvent:
                                          MainButtonEvent
                                              .startStopRecommendation)),
                                );
                              },
                            ),
                            CustomButton(
                                margin: const EdgeInsets.only(left: 30),
                                height: values.mainPagePlayPauseButtonSize / 2,
                                width: values.mainPagePlayPauseButtonSize / 2,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(
                                        values.mainPagePlayPauseButtonSize /
                                            2 /
                                            2)),
                                icon: const Icon(
                                  Icons.skip_next,
                                  color: custom_colors.darkBlue,
                                  size: values.mainPagePlayPauseButtonSize / 3,
                                ),
                                onPressed: () =>
                                    bloc.add(const TouchEvent(
                                        touchEvent: MainTouchEvent
                                            .goToNextTrack)),
                                pressedBackground: custom_colors.greyGradient,
                                defaultBackground:
                                custom_colors.transparentGradient),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      );
                    }),
                Expanded(child: Container()),
              ],
            )
          ],
        ));
  }

  Widget _getCurrentlyPlayingTrack(MainPageState state) {
    if (state.playerState == null || state.playerState!.track == null) {
      // Can add design for when no track is being played
      return Container();
    }
    Track? track = state.playerState!.track;

    QuackTrack quackTrack = QuackTrack.trackToQuackTrack(track)!;

    return Container(
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
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                child: Image.network(quackTrack.imageUrl!)), //
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
                            maxLines: 1,
                            softWrap: false,
                            fontWeight: FontWeight.w900,
                            title: quackTrack.name,
                            textColor: Colors.white,
                            useOverflowReplacement: true,
                            alignmentGeometry: Alignment.bottomLeft,
                            padding: const EdgeInsets.only(
                                left: 0, top: 10, bottom: 5, right: 10),
                            margin: const EdgeInsets.all(0),
                          ),
                          CustomLabel(
                            alignmentGeometry: Alignment.topLeft,
                            height: values.mainPageOverlayHeight / 2,
                            fontSize: 14,
                            maxLines: 1,
                            softWrap: false,
                            useOverflowReplacement: true,
                            margin: const EdgeInsets.all(0),
                            padding: const EdgeInsets.only(
                                left: 0, top: 5, bottom: 10, right: 10),
                            title: quackTrack.artist,
                            textColor: custom_colors.darkGrey,
                          )
                        ],
                      )))),
        ],
      ),
    );
  }

  Widget _getTrack(MainPageState state, QuackTrack? quackTrack) {
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
                    border:
                    Border.all(width: 0, color: custom_colors.darkBlue)),
                margin: const EdgeInsets.all(0),
                width: values.mainPageOverlayHeight,
                padding: const EdgeInsets.all(10),
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
                            textColor: state.currentTrack == quackTrack
                                ? custom_colors.orange_1
                                : Colors.white,
                            alignmentGeometry: Alignment.centerLeft,
                            padding: EdgeInsets.only(
                                left: 0,
                                top: 10,
                                bottom: 5,
                                right: state.currentTrack == quackTrack
                                    ? 0
                                    : 10),
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
                            padding: EdgeInsets.only(
                                left: 0,
                                top: 5,
                                bottom: 10,
                                right: state.currentTrack == quackTrack
                                    ? 0
                                    : 10),
                            title: quackTrack.artist,
                            textColor: custom_colors.darkGrey,
                          )
                        ],
                      ))),
              if (state.currentTrack == quackTrack)
                Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border:
                      Border.all(width: 0, color: custom_colors.darkBlue)),
                  width: values.mainPageOverlayHeight,
                  padding: const EdgeInsets.all(10),
                  child: Center(
                      child: CustomButton(
                          fontWeight: FontWeight.bold,
                          height: 50,
                          width: 50,
                          borderRadius:
                          const BorderRadius.all(Radius.circular(25)),
                          icon: Icon(
                            state.playerState!.isPaused
                                ? Icons.play_arrow
                                : Icons.pause,
                            color: Colors.white,
                            size: values.mainPageOverlayHeight / 2,
                          ),
                          onPressed: () =>
                              bloc.add(const ButtonPressed(
                                  buttonEvent: MainButtonEvent
                                      .resumePausePlayer)),
                          textColor: custom_colors.black,
                          pressedBackground:
                          custom_colors.backButtonGradientPressedDefault,
                          defaultBackground:
                          custom_colors.transparentGradient)),
                )
            ],
          ),
        ),
        onPressed: () => bloc.add(TrackSelected(quackTrack: quackTrack)));
  }

  Widget _getPlaylist(MainPageState state) {
    List<QuackTrack>? tracks = state.playlist!.tracks;

    return ListView.builder(
      itemCount: tracks!.length,
      itemBuilder: (context, index) {
        return _getTrack(state, tracks[index]);
      },
    );
  }

//endregion
}
