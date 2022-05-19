import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;

// ignore: must_be_immutable
class CustomDrawerTile extends StatefulWidget {
  String text;
  Icon icon;
  final Gradient defaultBackground;
  final Gradient pressedBackground;
  final VoidCallback onPressed;
  EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight fontWeight;

  CustomDrawerTile(
      {Key? key,
      this.padding = const EdgeInsets.all(5),
      this.fontSize = 20,
      this.fontWeight = FontWeight.bold,
      required this.text,
      required this.onPressed,
      required this.icon,
      this.defaultBackground = custom_colors.whiteGradient,
      this.pressedBackground = custom_colors.greyGradient})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomDrawerTileState();
}

class _CustomDrawerTileState extends State<CustomDrawerTile> {
  ///
  /// VARIABLES
  ///
  //region Variables

  bool _isPressed = false;
  Timer? _timer;

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  void initState() {
    _isPressed = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double preferredHeight = 60;

    TextStyle textStyle = TextStyle(
        color: Colors.white,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        decoration: BoxDecoration(
          gradient:
              _isPressed ? widget.pressedBackground : widget.defaultBackground,
        ),
        child: SizedBox(
          height: preferredHeight,
          child: Row(
            children: [
              Container(
                  width: preferredHeight,
                  child: Center(child: widget.icon),
                  padding: widget.padding),
              Expanded(
                  child: AutoSizeText(
                widget.text,
                style: GoogleFonts.roboto(
                    textStyle: textStyle, color: custom_colors.darkBlue),
                minFontSize: 5,
              ))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  //endregion

  //region Methods

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    widget.onPressed();
    // On a quick tap the pressed state is not shown, because the state
    // changes too fast, hence we introduce a delay.
    _timer = Timer(const Duration(milliseconds: 100),
        () => setState(() => _isPressed = false));
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

//endregion
}
