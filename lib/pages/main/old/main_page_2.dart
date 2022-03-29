import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/localization/localization_helper.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:smartphone_app/widgets/custom_list_tile.dart';
import 'package:spotify_sdk/models/track.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:geolocator_android/src/types/foreground_settings.dart';

import '../../../helpers/position_helper/udp_position_helper.dart';
import '../../../services/webservices/quack/models/quack_classes.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_drawer_tile.dart';
import '../../../widgets/custom_play_button.dart';
import '../main_page_bloc.dart';
import '../main_page_events_states.dart';

class MainPage2 extends StatefulWidget {
  const MainPage2({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class RoundShape extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double height = size.height;
    double width = size.width;
    double curveHeight = size.height / 2;
    var p = Path();
    p.lineTo(0, height - curveHeight);
    p.quadraticBezierTo(width / 2, height, width, height - curveHeight);
    p.lineTo(width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}

class _MainPageState extends State<MainPage2> with TickerProviderStateMixin {
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
    LocalizationHelper.init(context: context);
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

    var availableHeight = MediaQuery.of(context).size.height -
        values.actionBarHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    playlistHeight = availableHeight -
        values.mainPageOverlayButtonHeight -
        values.mainPageOverlayTopMargin;

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

  bool _shouldUpdateQuackLocationType(
      MainPageState previous, MainPageState current) {
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

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
              height: state.playlist == null
                  ? 0
                  : values.mainPageOverlayButtonHeight,
              duration: const Duration(milliseconds: 200),
              child: CustomButton(
                  fontWeight: FontWeight.bold,
                  height: null,
                  icon: Icon(
                    state.isPlaylistShown!
                        ? Icons.expand_more
                        : Icons.expand_less,
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
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                  margin: const EdgeInsets.all(0),
                  textColor: custom_colors.black,
                  pressedBackground: custom_colors.appButtonPressedGradient,
                  defaultBackground: custom_colors.appButtonGradient)),
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
        decoration:
            const BoxDecoration(gradient: custom_colors.mainPageGradient),
        padding: const EdgeInsets.only(
            bottom: values.mainPageOverlayHeight +
                values.mainPageOverlayButtonHeight),
        child: Column(
          children: [
            CustomAppBar(
              title: AppLocalizations.of(context)!.app_name,
              titleColor: Colors.white,
              appBarLeftButtonIconColor: Colors.white,
              background: custom_colors.appBarBackground,
              appBarLeftButton: AppBarLeftButton.menu,
              leftButtonPressed: () async =>
                  {_scaffoldKey.currentState!.openDrawer()},
            ),
            ClipPath(
              clipper: RoundShape(),
              child: Container(
                decoration: BoxDecoration(
                    color: custom_colors.darkBlue,
                    border:
                        Border.all(color: custom_colors.darkBlue, width: 0)),
                height: 20,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    BlocBuilder<MainPageBloc, MainPageState>(
                        buildWhen: (previous, current) {
                      return _shouldUpdateQuackLocationType(previous, current);
                    }, builder: (context, state) {
                      return Column(
                        children: [
                          Container(
                            child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: CustomLabel(
                                  key: UniqueKey(),
                                  textColor: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  alignmentGeometry: Alignment.center,
                                  margin: const EdgeInsets.all(0),
                                  padding: const EdgeInsets.all(0),
                                  title: LocalizationHelper.getInstance()
                                      .getLocalizedQuackLocationType(
                                          context,
                                          state.lockedQuackLocationType == null
                                              ? state.quackLocationType!
                                              : state.lockedQuackLocationType!),
                                )),
                            height: 40,
                            margin: const EdgeInsets.only(left: 30, right: 30),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: custom_colors.darkBlue),
                                color: custom_colors.darkBlue,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(27.5),
                                    topRight: Radius.circular(27.5))),
                          ),
                          Expanded(
                              child: AnimatedSwitcher(
                                  child: Container(
                                    key: UniqueKey(),
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(27.5))),
                                    padding: const EdgeInsets.all(0),
                                    margin: const EdgeInsets.only(
                                        top: 0, left: 30, right: 30, bottom: 0),
                                    child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(27.5),
                                            bottomRight: Radius.circular(27.5)),
                                        child: Image.asset(
                                          LocalizationHelper.getInstance()
                                              .getQuackLocationTypeImagePath(
                                                  state.lockedQuackLocationType ==
                                                          null
                                                      ? state.quackLocationType!
                                                      : state
                                                          .lockedQuackLocationType!),
                                          key: UniqueKey(),
                                          height: double.infinity,
                                          width: double.infinity,
                                          fit: BoxFit.fill,
                                        )),
                                  ),
                                  duration: const Duration(milliseconds: 500)))
                        ],
                      );
                    }),
                    BlocBuilder<MainPageBloc, MainPageState>(
                        builder: (context, state) {
                      return Align(
                        alignment: Alignment.bottomRight,
                        child: PlayButton(
                            margin:
                                const EdgeInsets.only(bottom: 10, right: 40),
                            width: 40,
                            height: 40,
                            foreground: Icon(
                              state.lockedQuackLocationType == null
                                  ? Icons.lock_outline
                                  : Icons.lock_open_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () => bloc.add(const ButtonPressed(
                                buttonEvent: MainButtonEvent
                                    .lockUnlockQuackLocationType)),
                            pressedBackground:
                                custom_colors.appButtonPressedGradient,
                            defaultBackground: custom_colors.appButtonGradient),
                      );
                    }),
                  ],
                )),
            BlocBuilder<MainPageBloc, MainPageState>(builder: (context, state) {
              return AnimatedBuilder(
                animation: startStopRecommendationController,
                builder: (context, _) {
                  return PlayButton(
                    margin: const EdgeInsets.only(top: 30, bottom: 30),
                    height: values.mainPagePlayPauseButtonSize,
                    width: values.mainPagePlayPauseButtonSize,
                    defaultBackground: custom_colors.appButtonGradient,
                    pressedBackground: custom_colors.appButtonPressedGradient,
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
                    onPressed: () => bloc.add(const ButtonPressed(
                        buttonEvent: MainButtonEvent.startStopRecommendation)),
                  );
                },
              );
            }),
            BlocBuilder<MainPageBloc, MainPageState>(builder: (context, state) {
              return CustomButton(
                  fontWeight: FontWeight.w700,
                  icon: const Icon(
                    Icons.tune_outlined,
                    color: Colors.white,
                  ),
                  margin: const EdgeInsets.only(left: 30, right: 30),
                  borderRadius: const BorderRadius.all(Radius.circular(55 / 2)),
                  text: AppLocalizations.of(context)!.preference_profile,
                  onPressed: () {},
                  textColor: Colors.white,
                  pressedBackground: custom_colors.appButtonPressedGradient,
                  defaultBackground: custom_colors.appButtonGradient);
            }),
            Expanded(child: Container()),
          ],
        ));
  }

  Widget _getCurrentlyPlayingTrack(MainPageState state) {
    Track? track = state.playerState!.track;
    if (track == null) {
      // Can add design for when no track is being played
      return Container();
    }

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
          Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 0, color: custom_colors.darkBlue)),
            width: values.mainPageOverlayHeight,
            padding: const EdgeInsets.all(10),
            child: Center(
                child: CustomButton(
                    fontWeight: FontWeight.bold,
                    height: 50,
                    width: 50,
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    icon: Icon(
                      state.playerState!.isPaused
                          ? Icons.play_arrow
                          : Icons.pause,
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
                        right: state.currentTrack == quackTrack ? 0 : 10),
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
                        right: state.currentTrack == quackTrack ? 0 : 10),
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
                          onPressed: () => bloc.add(const ButtonPressed(
                              buttonEvent: MainButtonEvent.resumePausePlayer)),
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
