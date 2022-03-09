import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartphone_app/utilities/general_util.dart';

// ignore: must_be_immutable
class CustomTextField extends StatefulWidget {
  final TextAlign textAlign;
  final bool readOnly;
  final TextInputType keyBoardType;

  final double? height;
  final double fontSize;
  final String? initialValue;
  String? text;
  String? hint;
  final TextInputAction? textInputAction;
  bool enabled;
  final int? maxLength;
  final int? maxLines;
  Alignment alignment;
  bool showClearButton;

  List<TextInputFormatter>? inputFormatters = [];
  final EdgeInsetsGeometry margin;
  final ValueChanged<String>? onChanged;

  CustomTextField(
      {Key? key,
      this.showClearButton = false,
      this.maxLength,
      this.height = 55,
      this.fontSize = 20,
      this.hint,
      this.alignment = Alignment.center,
      this.maxLines = 1,
      this.textAlign = TextAlign.left,
      this.readOnly = false,
      this.keyBoardType = TextInputType.text,
      this.onChanged,
      this.enabled = true,
      this.text,
      this.margin =
          const EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 0),
      this.textInputAction,
      this.initialValue})
      : super(key: key) {
    inputFormatters ??= [];
  }

  @override
  State<StatefulWidget> createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  final TextEditingController _textEditingController = TextEditingController();

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    GeneralUtil.setTextEditingControllerText(
        _textEditingController, widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    GeneralUtil.setTextEditingControllerText(
        _textEditingController, widget.text);

    return Container(
        margin: widget.margin,
        height: widget.height,
        padding: const EdgeInsets.only(left: 8, right: 8),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Align(
            alignment: widget.alignment,
            child: TextFormField(
              maxLength: widget.maxLength,
              style: GoogleFonts.roboto(
                  textStyle: TextStyle(fontSize: widget.fontSize)),
              keyboardType: widget.keyBoardType,
              controller: _textEditingController,
              onChanged: (value) {
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  suffixIcon: widget.showClearButton &&
                          widget.text != null &&
                          widget.text!.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _textEditingController.clear();
                            if (widget.onChanged != null) {
                              widget.onChanged!("");
                            }
                          },
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.black,
                          ),
                        )
                      : null,
                  hintText: widget.hint),
              inputFormatters: widget.inputFormatters,
              enabled: widget.enabled,
              textInputAction: widget.textInputAction,
              maxLines: widget.maxLines,
              buildCounter: (context,
                      {currentLength = 0, isFocused = false, maxLength}) =>
                  null,
            )));
  }

//endregion

}
