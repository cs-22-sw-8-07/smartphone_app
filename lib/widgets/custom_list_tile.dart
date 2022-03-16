import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/values/values.dart' as values;

// ignore: must_be_immutable
class CustomListTile extends StatefulWidget {
  final Gradient defaultBackground;
  final Gradient pressedBackground;
  final VoidCallback onPressed;
  final Widget widget;
  late BorderRadiusGeometry? borderRadius;

  // ignore: prefer_const_constructors_in_immutables
  CustomListTile(
      {Key? key,
      required this.widget,
      required this.onPressed,
      this.borderRadius,
      this.defaultBackground = custom_colors.whiteGradient,
      this.pressedBackground = custom_colors.greyGradient})
      : super(key: key) {
    borderRadius ??=
        const BorderRadius.all(Radius.circular(values.borderRadius));
  }

  @override
  State<StatefulWidget> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
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
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          gradient:
              _isPressed ? widget.pressedBackground : widget.defaultBackground,
        ),
        child: widget.widget,
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
