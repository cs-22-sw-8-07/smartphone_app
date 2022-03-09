import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const Color blue = Color(0xFF0067B0);
const Color lightBlue = Color(0xFF00AEEF);
const Color orange_1 = Color(0xFFF58220);
const Color orange_2 = Color(0xFFFFA500);
const Color orange3 = Color(0xFFEB9800);
const Color transparent = Color(0x00000000);
const Color transparentWhite = Color(0x20FFFFFF);
const Color black = Color(0xFF202020);
const Color black2 = Color(0xFF252525);
const Color darkGrey = Color(0xFF808080);

const Color appBarColor = Color(0xFF202020);
const Color borderColor = Color(0xFFFFFFFF);
const Color appSafeAreaColor = Color(0xFF202020);
const Color loginTopColor = Color(0xFFFFFFFF);
const Color loginBottomColor = Color(0xFF07B7E8);

const Color yellow1 = Color(0xFFFCC62B);
const Color yellow2 = Color(0xFFF0BC29);

const Color yellowTransparent1 = Color(0x80FCC62B);
const Color orangeTransparent3 = Color(0x80EB9800);

const Color yellowWhite1 = Color(0xFFFCFCEF);
const Color grey1 = Color(0xFFF0F0F0);
const Color grey2 = Color(0xFFE0E0E0);

const Color spotifyGreen = Color(0xFF1EC860);
const Color spotifyGreenPressed = Color(0xFF179648);

const Color contentDivider = Color(0xFFD0D0D0);

const LinearGradient loginBackground = LinearGradient(
    colors: <Color>[Colors.white, Colors.white],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const LinearGradient appBarBackground = LinearGradient(
    colors: <Color>[Colors.transparent, Colors.transparent],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));

const Gradient whiteGradient = LinearGradient(
    colors: <Color>[Colors.white, Colors.white],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const Gradient greyGradient = LinearGradient(
    colors: <Color>[grey1, grey1],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const Gradient greyGradient2 = LinearGradient(
    colors: <Color>[grey2, grey2],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));

const Gradient darkGreyGradient = LinearGradient(
    colors: <Color>[black, black],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));

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

const Gradient buttonDefaultGradient = LinearGradient(
    colors: <Color>[yellow1, orange3],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const Gradient buttonPressedGradient = LinearGradient(
  begin: Alignment(0.0, -1.0),
  end: Alignment(0.0, 1.0),
  colors: <Color>[orange_2, orange_2],
);
const Gradient backButtonGradientPressedDefault = LinearGradient(
  begin: Alignment(0.0, -1.0),
  end: Alignment(0.0, 1.0),
  colors: <Color>[transparentWhite, transparentWhite],
);

const Gradient blackGradient = LinearGradient(
    colors: <Color>[black, black],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const Gradient blackPressedGradient = LinearGradient(
    colors: <Color>[black2, black2],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));

const Gradient transparentGradient = LinearGradient(
  begin: Alignment(0.0, -1.0),
  end: Alignment(0.0, 1.0),
  colors: <Color>[transparent, transparent],
);
