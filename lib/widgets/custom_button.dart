import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;

class CustomButton extends StatefulWidget {
  ///
  /// VARIABLES
  ///
  //region Variables

  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  final String? text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textColor;

  final AssetImage? image;
  final Icon? icon;
  final EdgeInsetsGeometry imagePadding;

  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final bool showBorder;

  final Gradient? defaultBackground;
  final Gradient? pressedBackground;
  final BoxShadow? boxShadow;

  final VoidCallback onPressed;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  // ignore: prefer_const_constructors_in_immutables
  CustomButton({
    Key? key,
    this.text,
    this.fontSize = 20,
    this.fontWeight = FontWeight.normal,
    this.textColor = Colors.black,
    this.width,
    this.boxShadow,
    this.height = 55.0,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.all(0),
    this.border,
    this.borderRadius = const BorderRadius.all(Radius.circular(5.0)),
    this.showBorder = false,
    this.icon,
    this.image,
    this.imagePadding = const EdgeInsets.all(0),
    this.defaultBackground = custom_colors.buttonDefaultGradient,
    this.pressedBackground = custom_colors.buttonPressedGradient,
    required this.onPressed,
  })  : assert(
            (text == null && (image != null || icon != null)) || text != null),
        assert(image == null || icon == null),
        super(key: key);

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  CustomButtonState createState() => CustomButtonState();

//endregion
}

class CustomButtonState extends State<CustomButton> {
  ///
  /// STATIC VARIABLES
  ///
  //region Static variables

  static const Color _border = custom_colors.borderColor;

  //endregion

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
    List<BoxShadow> boxShadows = [];
    if (widget.boxShadow != null) {
      boxShadows = [widget.boxShadow!];
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        margin: widget.margin,
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
            gradient: _isPressed
                ? widget.pressedBackground
                : widget.defaultBackground,
            borderRadius: widget.borderRadius,
            border: !widget.showBorder
                ? null
                : widget.border ?? Border.all(color: _border, width: 1),
            boxShadow: boxShadows),
        child: buildWidgetsOnButton(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  //endregion

  ///
  /// METHODS
  ///
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

  Widget buildWidgetsOnButton() {
    Widget? imageWidget;
    if (widget.image != null) {
      imageWidget = Image(
        fit: BoxFit.cover,
        image: widget.image!,
      );
    } else if (widget.icon != null) {
      imageWidget = AnimatedSwitcher(
        child: widget.icon,
        duration: const Duration(milliseconds: 100),
      );
    }

    if (widget.text != null) {
      final TextStyle textStyle = TextStyle(
          color: Colors.white,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight);

      Widget textWidget = Center(
          child: AutoSizeText(
        widget.text!,
        style:
            GoogleFonts.roboto(textStyle: textStyle, color: widget.textColor),
        minFontSize: 5,
      ));

      if (widget.image != null || widget.icon != null) {
        return Row(
          children: [
            Container(
                width: widget.height,
                child: Center(child: imageWidget),
                padding: widget.imagePadding),
            Expanded(child: textWidget)
          ],
        );
      } else {
        return textWidget;
      }
    } else {
      return Container(
          child: Center(child: imageWidget), padding: widget.imagePadding);
    }
  }

//endregion

}
