import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/localization/localization_helper.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:smartphone_app/widgets/custom_list_tile.dart';

import '../../helpers/position_helper/position_helper.dart';
import '../../services/webservices/quack/models/quack_classes.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_drawer_tile.dart';
import '../../widgets/custom_play_button.dart';
import 'main_page_bloc.dart';
import 'main_page_events_states.dart';

// ignore: must_be_immutable
class MainPage extends StatefulWidget {
  _MainPageState? state;

  MainPage({Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    state = _MainPageState();
    return state!;
  }

  MainPageBloc get bloc => state!.bloc;
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  ///
  /// VARIABLES
  ///
  //region Variables

  late MainPageBloc bloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late AnimationController playlistAnimationController;
  late AnimationController locationListAnimationController;
  Animation<double>? playlistSizeAnimation;
  Animation<double>? locationListSizeAnimation;
  late double playlistHeight;
  Image? userImage;
  Widget? userImageWidget;
  Image? locationShadowImage;

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

    // Get url to the user's profile image on Spotify
    var url =
        AppValuesHelper.getInstance().getString(AppValuesKey.userImageUrl) ??
            "";
    // If the user has no profile image show a placeholder instead
    if (url.isEmpty) {
      userImageWidget = Container(
          height: 60,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              border: Border.all(color: Colors.white, width: 2)),
          child: const Icon(Icons.person_outline_outlined,
              size: 35, color: custom_colors.darkBlue));
    } else {
      userImage = Image.network(
          AppValuesHelper.getInstance().getString(AppValuesKey.userImageUrl) ??
              "");
      userImageWidget = userImage;
    }

    locationShadowImage = Image.asset(
      values.locationShadowImage,
      fit: BoxFit.fitWidth,
    );

    // Setup animation controllers
    playlistAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    locationListAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Precache user image
    if (userImage != null) precacheImage(userImage!.image, context);

    // Precache location shadow image
    if (locationShadowImage != null) {
      precacheImage(locationShadowImage!.image, context);
    }
  }

  @override
  void dispose() {
    // Remember to dispose controllers
    playlistAnimationController.dispose();
    locationListAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create BLoC
    bloc = MainPageBloc(
        context: context,
        positionHelper:
            PositionHelper.getInstanceWithContext(context: context));

    // Get available width
    availableWidth = MediaQuery.of(context).size.width;
    // Get available height
    availableHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    // Calculate height of the playlist overlay
    playlistHeight = availableHeight - values.actionBarHeight;
    // Create playlist overlay height animation
    playlistSizeAnimation ??=
        Tween<double>(begin: values.mainPageOverlayHeight, end: playlistHeight)
            .animate(playlistAnimationController);
    // Create location overlay height animation
    locationListSizeAnimation ??= Tween<double>(begin: 0, end: availableHeight)
        .animate(locationListAnimationController);

    return WillPopScope(
        onWillPop: () async {
          if (bloc.state.isLocationListShown!) {
            bloc.add(const ButtonPressed(buttonEvent: MainButtonEvent.back));
            locationListAnimationController.reverse();
            return false;
          }
          else if (bloc.state.isPlaylistShown!) {
            bloc.add(const ButtonPressed(buttonEvent: MainButtonEvent.back));
            playlistAnimationController.reverse();
            return false;
          }
          return true;
        },
        child: FutureBuilder<bool>(
            future: bloc.getValues(),
            builder: (context, snapshot) {
              Widget? widget;

              // Show a progress indicator while getting values for page
              if (snapshot.connectionState != ConnectionState.done) {
                widget = Container(
                    color: Colors.white,
                    child: const Center(
                        child: SizedBox(
                      child: CircularProgressIndicator(
                          color: custom_colors.darkBlue),
                      height: 60,
                      width: 60,
                    )));
              } else {
                widget = BlocProvider(
                    create: (_) => bloc,
                    child: Container(
                        color: custom_colors.appSafeAreaColor,
                        child: SafeArea(
                            child: Scaffold(
                                key: _scaffoldKey,
                                drawer: _getDrawer(bloc),
                                body: _getContent(bloc)))));
              }

              return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1000), child: widget);
            }));
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  //region Helper methods

  /// Compare the [current] and [previous] state in order to determine if the
  /// QuackLocationType has changed. This method is used in order to avoid
  /// unnecessary animation updates when the image shown for a QuackLocationType
  /// should not change
  bool _shouldUpdateQuackLocationType(
      MainPageState previous, MainPageState current) {
    // Same QuackLocationType in both states and
    // LockedQuackLocationType is null in both states
    if (previous.quackLocationType == current.quackLocationType &&
        previous.lockedQuackLocationType == null &&
        current.lockedQuackLocationType == null) {
      return false;
    }

    // LockedQuackLocationType is not null in both states and
    // same LockedQuackLocationType in both states
    if (previous.lockedQuackLocationType != null &&
        current.lockedQuackLocationType != null &&
        previous.lockedQuackLocationType == current.lockedQuackLocationType) {
      return false;
    }

    // Different QuackLocationTypes in the states or
    //
    // LockedQuackLocationType in the current state is not null and it is
    // different from the QuackLocationType in the previous state or
    //
    // LockedQuackLocationType in the current state is null and
    // QuackLocationType in the current state is different from the
    // LockedQuackLocationType in the previous state
    return previous.quackLocationType != current.quackLocationType ||
        (current.lockedQuackLocationType != null &&
            current.lockedQuackLocationType != previous.quackLocationType) ||
        (current.lockedQuackLocationType == null &&
            current.quackLocationType != previous.lockedQuackLocationType);
  }

  //endregion

  //region Build methods

  /// Specifies the content on the page. It is called directly in the [build]
  /// method
  Widget _getContent(MainPageBloc bloc) {
    return Stack(
      children: [
        _getMainContent(bloc),
        _getPlaylistContent(bloc),
        _getLocationContent(bloc)
      ],
    );
  }

  /// Builds the drawer shown on the page
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
                              child: userImageWidget))
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
                    locationShadowImage!
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
                      buttonEvent: MainButtonEvent.seeHistory));
                },
                text: AppLocalizations.of(context)!.history,
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
                      const ButtonPressed(buttonEvent: MainButtonEvent.logOut));
                },
              ),
            ],
          )),
    );
  }

  /// Build the playlist overlay
  Widget _getPlaylistContent(MainPageBloc bloc) {
    return BlocBuilder<MainPageBloc, MainPageState>(builder: (context, state) {
      // When the playlist is not shown, the track currently being played is
      // shown in the bottom
      var overlayContent = state.isPlaylistShown!
          ? _getPlaylist(state)
          : _getCurrentlyPlayingTrack(state);

      // An expand/collapse button is always shown above the playlist or the
      // track currently being played
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
                            buttonEvent: MainButtonEvent.viewPlaylist));
                        bloc.state.isPlaylistShown!
                            ? playlistAnimationController.reverse()
                            : playlistAnimationController.forward();
                      },
                      borderRadius: const BorderRadius.all(
                        Radius.circular(0),
                      ),
                      margin: const EdgeInsets.all(0),
                      textColor: custom_colors.black,
                      pressedBackground: custom_colors.appButtonGradient,
                      defaultBackground: custom_colors.appButtonGradient),
                  // Only show the refresh button when the playlist is shown
                  // and there is no loading of playlists
                  if (state.isPlaylistShown! && !state.isLoading!)
                    Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: CustomButton(
                            fontWeight: FontWeight.bold,
                            height: 40,
                            width: 40,
                            icon: const Icon(
                              Icons.refresh_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              bloc.add(const ButtonPressed(
                                  buttonEvent:
                                      MainButtonEvent.refreshPlaylist));
                            },
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            margin: const EdgeInsets.only(
                                right: (values.actionBarHeight - 30) / 2),
                            textColor: custom_colors.black,
                            pressedBackground:
                                custom_colors.backButtonGradientPressedDefault,
                            defaultBackground:
                                custom_colors.transparentGradient),
                      ),
                    ),
                  // Only show the Spotify icon when the playlist is shown
                  // and there is no loading of playlists
                  if (state.isPlaylistShown! && !state.isLoading!)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                          padding: const EdgeInsets.only(
                              left: (values.actionBarHeight - 30) / 2),
                          child: const Image(
                              height: 30,
                              width: 30,
                              image: AssetImage(values.spotifyWhiteIcon))),
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

  /// Builds the overlay that allows the user to select a QuackLocationType
  /// manually
  Widget _getLocationContent(MainPageBloc bloc) {
    return BlocBuilder<MainPageBloc, MainPageState>(builder: (context, state) {
      return AnimatedBuilder(
          animation: locationListAnimationController,
          builder: (context, _) {
            Widget child;
            // If the flag is not set to show the location list or the height
            // animation has not completed, show a placeholder container
            if (!state.isLocationListShown! &&
                !locationListSizeAnimation!.isCompleted) {
              child = Container();
            } else {
              // List with a collapse button below
              child =
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                _getLocationList(state),
                CustomButton(
                    fontWeight: FontWeight.bold,
                    height: values.actionBarHeight,
                    icon: const Icon(
                      Icons.expand_less,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => {
                          bloc.add(const ButtonPressed(
                              buttonEvent:
                                  MainButtonEvent.selectManualLocation)),
                          bloc.state.isLocationListShown!
                              ? locationListAnimationController.reverse()
                              : locationListAnimationController.forward(),
                        },
                    borderRadius: const BorderRadius.all(
                      Radius.circular(0),
                    ),
                    margin: const EdgeInsets.all(0),
                    textColor: custom_colors.black,
                    pressedBackground: custom_colors.appButtonGradient,
                    defaultBackground: custom_colors.appButtonGradient)
              ]);
            }

            // This is the overlay container, which height is being animated
            return Container(
                decoration: BoxDecoration(
                    color: custom_colors.darkBlue,
                    border:
                        Border.all(color: custom_colors.darkBlue, width: 0)),
                height: locationListSizeAnimation!.value,
                child: child);
          });
    });
  }

  /// Builds the main content on the page
  Widget _getMainContent(MainPageBloc bloc) {
    return Container(
        decoration: const BoxDecoration(color: custom_colors.transparent),
        child: Stack(
          children: [
            BlocBuilder<MainPageBloc, MainPageState>(
                buildWhen: (previous, current) {
              return _shouldUpdateQuackLocationType(previous, current);
            }, builder: (context, state) {
              // Background image, displaying the currently assigned
              // QuackLocationType
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
                      border: Border.all(color: Colors.transparent, width: 0)),
                ))
              ],
            ),
            Column(
              children: [
                SizedBox(
                    height: values.actionBarHeight,
                    child: Stack(children: [
                      BlocBuilder<MainPageBloc, MainPageState>(
                          builder: (context, state) {
                        return CustomAppBar(
                          background: custom_colors.transparentGradient,
                          appBarLeftButtonIconColor: custom_colors.darkBlue,
                          buttonBackground: custom_colors.whiteGradient,
                          buttonPressedBackground: custom_colors.greyGradient,
                          appBarLeftButton: AppBarLeftButton.menu,
                          leftButtonPressed: () async =>
                              {_scaffoldKey.currentState!.openDrawer()},
                          button1Icon: Icon(
                            state.lockedQuackLocationType == null
                                ? Icons.lock_open_outlined
                                : Icons.lock_outlined,
                            color: Colors.black,
                          ),
                          onButton1Pressed: () => bloc.add(const ButtonPressed(
                              buttonEvent:
                                  MainButtonEvent.lockUnlockQuackLocationType)),
                        );
                      }),
                      Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                              onTapUp: (v) {
                                bloc.add(const ButtonPressed(
                                    buttonEvent:
                                        MainButtonEvent.selectManualLocation));
                                bloc.state.isLocationListShown!
                                    ? locationListAnimationController.reverse()
                                    : locationListAnimationController.forward();
                              },
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
                                                color: custom_colors.darkBlue,
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
                            icon: Icon(
                              Icons.skip_previous,
                              color: state.playlist == null
                                  ? custom_colors.darkGrey_2
                                  : custom_colors.darkBlue,
                              size: values.mainPagePlayPauseButtonSize / 3,
                            ),
                            onPressed: () {
                              if (state.playlist != null) {
                                bloc.add(const TouchEvent(
                                    touchEvent:
                                        MainTouchEvent.goToPreviousTrack));
                              }
                            },
                            pressedBackground: state.playlist == null
                                ? custom_colors.transparentGradient
                                : custom_colors.greyGradient,
                            defaultBackground:
                                custom_colors.transparentGradient),
                        PlayButton(
                          margin: const EdgeInsets.only(top: 30, bottom: 30),
                          height: values.mainPagePlayPauseButtonSize,
                          width: values.mainPagePlayPauseButtonSize,
                          defaultBackground: custom_colors.appButtonGradient,
                          pressedBackground:
                              custom_colors.appButtonPressedGradient,
                          isPlaying: state.playlist != null &&
                              state.playerState != null &&
                              !state.playerState!.isPaused,
                          foreground: state.isLoading!
                              ? Container(
                                  padding: const EdgeInsets.all(35),
                                  child: const CircularProgressIndicator(
                                      color: Colors.white))
                              : Icon(
                                  state.playlist != null &&
                                          state.playerState != null &&
                                          !state.playerState!.isPaused
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40),
                          onPressed: () => bloc.add(const ButtonPressed(
                              buttonEvent:
                                  MainButtonEvent.startStopRecommendation)),
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
                            icon: Icon(
                              Icons.skip_next,
                              color: state.playlist == null
                                  ? custom_colors.darkGrey_2
                                  : custom_colors.darkBlue,
                              size: values.mainPagePlayPauseButtonSize / 3,
                            ),
                            onPressed: () {
                              if (state.playlist != null) {
                                bloc.add(const TouchEvent(
                                    touchEvent: MainTouchEvent.goToNextTrack));
                              }
                            },
                            pressedBackground: state.playlist == null
                                ? custom_colors.transparentGradient
                                : custom_colors.greyGradient,
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

  /// Builds the overlay that shows the track currently being played
  Widget _getCurrentlyPlayingTrack(MainPageState state) {
    // When the playlist is shown the background is becoming darker in order to
    // create a contrast between this widget and the playlist
    Color backgroundColor = state.isPlaylistShown!
        ? custom_colors.darkerBlue
        : custom_colors.darkBlue;
    // If the player state is null or no track is currently being played show a
    // placeholder container
    if (state.playerState == null || state.playerState!.track == null) {
      return Container(
        decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(width: 0, color: custom_colors.darkBlue)),
        height: values.mainPageOverlayHeight,
      );
    }

    // Get track currently being played as a QuackTrack
    QuackTrack quackTrack = state.playerState!.track!;

    return Container(
      decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(width: 0, color: custom_colors.darkBlue)),
      height: values.mainPageOverlayHeight,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 0, color: backgroundColor)),
            margin: const EdgeInsets.all(0),
            width: values.mainPageOverlayHeight,
            padding: const EdgeInsets.all(values.padding),
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                child: Image.network(quackTrack.imageUrl!)), //
          ),
          Expanded(
              child: ClipRect(
                  child: Dismissible(
                      direction:
                          state.playlist == null || state.currentTrack == null
                              ? DismissDirection.none
                              : DismissDirection.horizontal,
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
                                left: 0,
                                top: values.padding,
                                bottom: values.padding / 2,
                                right: values.padding),
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
                                left: 0,
                                top: values.padding / 2,
                                bottom: values.padding,
                                right: values.padding),
                            title: quackTrack.artist,
                            textColor: custom_colors.darkGrey,
                          )
                        ],
                      )))),
          // Only show when the playlist is shown
          if (state.isPlaylistShown!)
            Container(
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(width: 0, color: backgroundColor)),
              width: values.mainPageOverlayHeight,
              padding: const EdgeInsets.all(values.padding),
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
          // Only show when the playlist is not shown
          if (!state.isPlaylistShown!)
            const SizedBox(
                width: 60,
                height: 60,
                child: Align(
                    alignment: Alignment.center,
                    child: Image(
                        height: 30,
                        width: 30,
                        image: AssetImage(values.spotifyWhiteIcon))))
        ],
      ),
    );
  }

  /// Builds a list item in the playlist for a given [quackTrack]
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
                    textColor: state.currentTrack == quackTrack
                        ? custom_colors.orange_1
                        : Colors.white,
                    alignmentGeometry: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                        left: 0,
                        top: values.padding,
                        bottom: 5,
                        right: state.currentTrack == quackTrack
                            ? 0
                            : values.padding),
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
                        bottom: values.padding,
                        right: state.currentTrack == quackTrack
                            ? 0
                            : values.padding),
                    title: quackTrack.artist,
                    textColor: custom_colors.darkGrey,
                  )
                ],
              ))),
            ],
          ),
        ),
        onPressed: () => bloc.add(TrackSelected(quackTrack: quackTrack)));
  }

  /// Builds the playlist shown in the playlist overlay
  Widget _getPlaylist(MainPageState state) {
    // If the isLoading flag is set, then show a process indicator
    if (state.isLoading!) {
      return const Center(
          child: SizedBox(
        child: CircularProgressIndicator(color: Colors.white),
        height: 60,
        width: 60,
      ));
    } else {
      List<QuackTrack>? tracks = state.playlist!.tracks;
      // If there are no tracks shown a placeholder container
      if (tracks == null) {
        return Container();
      }

      List<Widget> children = [];
      // Add the list items for each track
      for (var track in tracks) {
        children.add(_getTrack(state, track));
      }
      // Add retrieve button as the last item in the list
      children.add(CustomButton(
        onPressed: () => bloc.add(
            const ButtonPressed(buttonEvent: MainButtonEvent.appendToPlaylist)),
        text: AppLocalizations.of(context)!.retrieve,
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
      ));
      // The list is shown with a scrollbar that is always visible
      return Column(
        children: [
          Expanded(
              child: RawScrollbar(
                  isAlwaysShown: true,
                  thickness: 4,
                  thumbColor: Colors.white,
                  child: ListView(
                      padding: const EdgeInsets.all(0), children: children))),
          _getCurrentlyPlayingTrack(state)
        ],
      );
    }
  }

  /// Builds a list tile used in the list in location overlay
  ///
  /// [locationType] is used to identicate the image shown in the list tile
  /// If [useAutomaticTitle] is set, the title will become 'Automatic' instead
  /// of the name of the [locationType]
  /// If [isSelected] is set the title will be highlighted e.g. with an orange
  /// color
  Widget _getLocationListTile(
      MainPageState state, QuackLocationType locationType,
      {bool useAutomaticTitle = false, bool isSelected = false}) {
    return CustomListTile(
        pressedBackground: custom_colors.transparentGradient,
        defaultBackground: custom_colors.transparentGradient,
        widget: Container(
            decoration: BoxDecoration(
                color: custom_colors.darkBlue,
                border: Border.all(width: 0, color: custom_colors.darkBlue)),
            height: values.mainPageOverlayHeight,
            child: Row(children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border:
                        Border.all(width: 0, color: custom_colors.darkBlue)),
                margin: const EdgeInsets.all(0),
                width: values.mainPageOverlayHeight,
                padding: const EdgeInsets.all(values.padding),
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    child: Image.asset(LocalizationHelper.getInstance()
                        .getQuackLocationTypeSmallImagePath(locationType))), //
              ),
              CustomLabel(
                  height: values.mainPageOverlayHeight / 2,
                  fontSize: 15,
                  maxLines: 1,
                  softWrap: false,
                  useOverflowReplacement: true,
                  fontWeight: FontWeight.w700,
                  title: useAutomaticTitle
                      ? AppLocalizations.of(context)!.automatic
                      : LocalizationHelper.getInstance()
                          .getLocalizedQuackLocationType(context, locationType),
                  textColor: isSelected ? custom_colors.orange_1 : Colors.white,
                  alignmentGeometry: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                      left: 0, top: 0, bottom: 0, right: values.padding),
                  margin: const EdgeInsets.all(0))
            ])),
        onPressed: () {
          bloc.add(LocationSelected(
              quackLocationType: useAutomaticTitle ? null : locationType));
          bloc.state.isLocationListShown!
              ? locationListAnimationController.reverse()
              : locationListAnimationController.forward();
        });
  }

  /// Builds the list shown in the location overlay
  Widget _getLocationList(MainPageState state) {
    List<Widget> children = [
      _getLocationListTile(state, state.quackLocationType!,
          useAutomaticTitle: true,
          isSelected: state.lockedQuackLocationType == null),
      Container(
        margin:
            const EdgeInsets.only(left: values.padding, right: values.padding),
        color: custom_colors.lightDarkBlue,
        height: 2,
      )
    ];

    // Go through every QuackLocationType
    for (var locationType in QuackLocationType.values) {
      // Skip the 'Unknown' QuackLocationType
      if (locationType == QuackLocationType.unknown) {
        continue;
      }
      // Add items to the list
      children.add(_getLocationListTile(state, locationType,
          isSelected: state.lockedQuackLocationType == locationType));
    }
    // The list is shown with a scrollbar that is always visible
    return Expanded(
        child: RawScrollbar(
            isAlwaysShown:
                locationListSizeAnimation!.isCompleted ? true : false,
            thickness: 4,
            thumbColor: Colors.white,
            child: ListView(
              children: children,
              shrinkWrap: true,
            )));
  }

//endregion

//endregion
}
