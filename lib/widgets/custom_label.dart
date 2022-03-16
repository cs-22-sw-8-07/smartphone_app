import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;

class CustomLabel extends StatelessWidget {
  ///
  /// VARIABLES
  ///
  //region Variables

  final String? title;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign textAlign;
  final AlignmentGeometry alignmentGeometry;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color textColor;
  final Gradient background;
  final double? height;
  final bool isWrapping;
  final double? width;
  final BorderRadius? borderRadius;
  final int? maxLines;
  final TextOverflow textOverflow;
  final bool? softWrap;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  // ignore: prefer_const_constructors_in_immutables
  CustomLabel(
      {Key? key,
      required this.title,
      this.fontSize = 20,
      this.height,
      this.softWrap,
      this.textOverflow = TextOverflow.fade,
      this.width,
      this.maxLines,
      this.isWrapping = false,
      this.background = custom_colors.transparentGradient,
      this.borderRadius,
      this.margin = const EdgeInsets.all(10),
      this.padding = const EdgeInsets.only(top: 2),
      this.fontWeight = FontWeight.normal,
      this.textAlign = TextAlign.center,
      this.textColor = Colors.black,
      this.alignmentGeometry = Alignment.centerLeft})
      : super(key: key);

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Widget build(BuildContext context) {
    if (isWrapping) {
      return Container(
        decoration: BoxDecoration(gradient: background),
        margin: margin,
        padding: padding,
        height: height,
        width: width,
        child: Text(
          title ?? "",
          softWrap: softWrap,
          maxLines: maxLines,
          style: GoogleFonts.roboto(
              textStyle: TextStyle(
                  color: textColor,
                  fontWeight: fontWeight,
                  fontSize: fontSize)),
        ),
      );
    } else {
      return Container(
          decoration: BoxDecoration(gradient: background),
          margin: margin,
          padding: padding,
          height: height,
          width: width,
          child: Align(
            alignment: alignmentGeometry,
            child: Text(
              title ?? "",
              softWrap: softWrap,
              maxLines: maxLines,
              overflow: textOverflow,
              textAlign: textAlign,
              style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                      color: textColor,
                      fontWeight: fontWeight,
                      fontSize: fontSize)),
            ),
          ));
    }
  }

//endregion

}
