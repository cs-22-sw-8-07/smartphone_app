import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/values/values.dart' as values;

import 'custom_button.dart';

enum AppBarLeftButton { menu, back, close }

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  ///
  /// VARIABLES
  ///
  //region Variables

  final String title;
  final Color titleColor;
  final LinearGradient background;
  final VoidCallback? leftButtonPressed;

  final AssetImage? button1Image;
  final AssetImage? button2Image;
  final Icon? button1Icon;
  final Icon? button2Icon;

  final VoidCallback? onButton1Pressed;
  final VoidCallback? onButton2Pressed;

  final AppBarLeftButton appBarLeftButton;

  @override
  final Size preferredSize = const Size.fromHeight(56.0);

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  const CustomAppBar(
      {Key? key,
      required this.title,
      required this.titleColor,
      required this.background,
      this.button1Image,
      this.button1Icon,
      this.onButton1Pressed,
      this.button2Image,
      this.button2Icon,
      this.onButton2Pressed,
      this.appBarLeftButton = AppBarLeftButton.back,
      this.leftButtonPressed})
      : assert((button1Icon == null && button1Image == null) ||
            (button1Icon != null && button1Image == null) ||
            (button1Icon == null && button1Image != null)),
        assert((button2Icon == null && button2Image == null) ||
            (button2Icon != null && button2Image == null) ||
            (button2Icon == null && button2Image != null)),
        super(key: key);

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      child: Stack(
        children: [
          Center(
              child: Container(
            child: Text(
              title,
              style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: titleColor)),
            ),
            margin: const EdgeInsets.only(left: 0.0),
          )),
          Row(
            children: [
              CustomButton(
                  height: preferredSize.height - 12,
                  width: preferredSize.height - 12,
                  margin: const EdgeInsets.only(left: 8),
                  imagePadding: const EdgeInsets.all(10),
                  showBorder: false,
                  borderRadius: const BorderRadius.all(Radius.circular(22)),
                  defaultBackground: custom_colors.transparentGradient,
                  pressedBackground:
                      custom_colors.backButtonGradientPressedDefault,
                  icon: _getLeftButtonIcon(appBarLeftButton),
                  onPressed: leftButtonPressed!),
              Expanded(child: Container()),
              if (onButton2Pressed != null)
                CustomButton(
                    height: preferredSize.height - 12,
                    width: preferredSize.height - 12,
                    margin: const EdgeInsets.only(right: 8),
                    imagePadding: const EdgeInsets.all(6),
                    showBorder: false,
                    borderRadius: const BorderRadius.all(Radius.circular(22)),
                    defaultBackground: custom_colors.transparentGradient,
                    pressedBackground:
                        custom_colors.backButtonGradientPressedDefault,
                    image: button2Image,
                    icon: button2Icon,
                    onPressed: onButton2Pressed!),
              if (onButton1Pressed != null)
                CustomButton(
                    height: preferredSize.height - 12,
                    width: preferredSize.height - 12,
                    margin: const EdgeInsets.only(right: 8),
                    imagePadding: const EdgeInsets.all(6),
                    showBorder: false,
                    borderRadius: const BorderRadius.all(Radius.circular(22)),
                    defaultBackground: custom_colors.transparentGradient,
                    pressedBackground:
                        custom_colors.backButtonGradientPressedDefault,
                    image: button1Image,
                    icon: button1Icon,
                    onPressed: onButton1Pressed!),
            ],
          )
        ],
      ),
      decoration: BoxDecoration(
          gradient: background,
          border: Border.all(color: custom_colors.darkBlue, width: 0)),
    );
  }

  Icon _getLeftButtonIcon(AppBarLeftButton appBarLeftButton) {
    switch (appBarLeftButton) {
      case AppBarLeftButton.menu:
        return const Icon(Icons.menu, color: Colors.white);
      case AppBarLeftButton.back:
        return const Icon(Icons.arrow_back, color: Colors.black);
      case AppBarLeftButton.close:
        return const Icon(Icons.clear, color: Colors.black);
    }
  }

//endregion

}
