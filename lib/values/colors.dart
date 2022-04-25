import 'package:flutter/material.dart';

///
/// COLORS
///
//region Colors

const Color borderColor = Color(0xFFFFFFFF);
const Color appSafeAreaColor = Color(0xFF202020);

const Color darkBlue = Color(0xFF3B3D4D);
const Color darkerBlue = Color(0xFF2F313D);
const Color lightDarkBlue = Color(0xFF666985);
const Color orange_1 = Color(0xFFF58220);
const Color black = Color(0xFF202020);
const Color black_2 = Color(0xFF252525);
const Color grey_1 = Color(0xFFF0F0F0);
const Color darkGrey = Color(0xFFD0D0D0);
const Color darkGrey_2 = Color(0xFFA0A0A0);
const Color transparent = Color(0x00FFFFFF);

const Color white_1 = Color(0xA0FFFFFF);
const Color white_2 = Color(0x20FFFFFF);

const Color spotifyGreen = Color(0xFF1EC860);
const Color spotifyGreenPressed = Color(0xFF179648);

//endregion

///
/// GRADIENTS
///
//region Gradients

const Gradient whiteGradient = LinearGradient(
    colors: <Color>[Colors.white, Colors.white],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const Gradient transparentWhiteGradient = LinearGradient(colors: <Color>[
  transparent,
  transparent,
  white_1,
  Colors.white,
  Colors.white,
  Colors.white
], begin: Alignment(0.0, -1.0), end: Alignment(0.0, 1.0));
const Gradient greyGradient = LinearGradient(
    colors: <Color>[grey_1, grey_1],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const Gradient transparentGradient = LinearGradient(
  begin: Alignment(0.0, -1.0),
  end: Alignment(0.0, 1.0),
  colors: <Color>[transparent, transparent],
);

const Gradient buttonDefaultGradient = LinearGradient(
    colors: <Color>[darkBlue, darkBlue],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const Gradient buttonPressedGradient = LinearGradient(
  begin: Alignment(0.0, -1.0),
  end: Alignment(0.0, 1.0),
  colors: <Color>[black_2, black_2],
);
const Gradient backButtonGradientPressedDefault = LinearGradient(
  begin: Alignment(0.0, -1.0),
  end: Alignment(0.0, 1.0),
  colors: <Color>[white_2, white_2],
);

const Gradient spotifyGradient = LinearGradient(
  begin: Alignment(0.0, -1.0),
  end: Alignment(0.0, 1.0),
  colors: <Color>[spotifyGreen, spotifyGreen],
);
const Gradient spotifyPressedGradient = LinearGradient(
  begin: Alignment(0.0, -1.0),
  end: Alignment(0.0, 1.0),
  colors: <Color>[spotifyGreenPressed, spotifyGreenPressed],
);

const LinearGradient loginBackground = LinearGradient(
    colors: <Color>[Colors.white, Colors.white],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const Gradient appButtonGradient = LinearGradient(
    colors: <Color>[darkBlue, darkBlue],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const Gradient appButtonPressedGradient = LinearGradient(
    colors: <Color>[darkerBlue, darkerBlue],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));

//endregion
