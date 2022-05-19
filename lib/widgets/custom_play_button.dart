import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;

// ignore: must_be_immutable
class PlayButton extends StatefulWidget {
  final bool isPlaying;
  final Widget foreground;
  final VoidCallback onPressed;
  final Gradient defaultBackground;
  final Gradient pressedBackground;
  EdgeInsets? padding;
  EdgeInsets? margin;
  double? width;
  double? height;

  PlayButton({
    Key? key,
    required this.onPressed,
    this.padding,
    this.margin,
    this.defaultBackground = custom_colors.buttonDefaultGradient,
    this.pressedBackground = custom_colors.buttonPressedGradient,
    this.isPlaying = false,
    this.width,
    this.height,
    this.foreground = const Icon(Icons.play_arrow),
  }) : super(key: key);

  @override
  _PlayButtonState createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> with TickerProviderStateMixin {
  ///
  /// STATICS
  ///
  //region Statics

  static const _kToggleDuration = Duration(milliseconds: 300);
  static const _kRotationDuration = Duration(seconds: 5);

  //endregion

  ///
  /// VARIABLES
  ///
  //region Variables

  late bool _isPressed;
  Timer? _timer;

  // Animations
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  double _rotation = 0;
  double _scale = 0.85;

  //endregion

  ///
  /// PROPERTIES
  ///
  //region Properties

  bool get _showWaves => !_scaleController.isDismissed;

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  void _updateRotation() => _rotation = _rotationController.value * 2 * pi;

  void _updateScale() => _scale = (_scaleController.value * 0.2) + 0.85;

  void _playAnimation() {
    _scaleController.forward();
  }

  void _stopAnimation() {
    _scaleController.reverse();
  }

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

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  void initState() {
    _isPressed = false;
    _rotationController =
        AnimationController(vsync: this, duration: _kRotationDuration)
          ..addListener(() => setState(_updateRotation))
          ..repeat();

    _scaleController =
        AnimationController(vsync: this, duration: _kToggleDuration)
          ..addListener(() => setState(_updateScale));

    super.initState();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPlaying) {
      _playAnimation();
    } else {
      _stopAnimation();
    }

    return GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          margin: widget.margin,
          height: widget.height,
          width: widget.width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_showWaves) ...[
                Blob(
                    color: const Color(0xffFAC172),
                    scale: _scale,
                    rotation: _rotation),
                Blob(
                    color: const Color(0xffED688A),
                    scale: _scale,
                    rotation: _rotation * 2 - 30),
                Blob(
                    color: const Color(0xff6378FA),
                    scale: _scale,
                    rotation: _rotation * 3 - 45),
                /*Blob(
                    color: const Color(0xFFE18700),
                    scale: _scale,
                    rotation: _rotation),
                Blob(
                    color: const Color(0xFF0047AB),
                    scale: _scale,
                    rotation: _rotation * 3 - 30),
                Blob(
                    color: const Color(0xFFFFB508),
                    scale: _scale,
                    rotation: _rotation * 3.5 - 45),
                Blob(
                    color: const Color(0xFF0058D4),
                    scale: _scale,
                    rotation: _rotation * 4 - 60),*/
              ],
              Container(
                constraints: const BoxConstraints.expand(),
                padding: widget.padding,
                child: AnimatedSwitcher(
                  child: widget.foreground,
                  duration: _kToggleDuration,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _isPressed
                      ? widget.pressedBackground
                      : widget.defaultBackground,
                ),
              ),
            ],
          ),
        ));
  }

//endregion
}

class Blob extends StatelessWidget {
  final double rotation;
  final double scale;
  final Color color;

  const Blob({Key? key, required this.color, this.rotation = 0, this.scale = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(150),
              topRight: Radius.circular(240),
              bottomLeft: Radius.circular(220),
              bottomRight: Radius.circular(180),
            ),
          ),
        ),
      ),
    );
  }
}
