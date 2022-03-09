import 'package:flutter/material.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class CustomProgressDialog extends StatelessWidget {
  ///
  /// VARIABLES
  ///
  //region Variables

  final Future future;
  final Function(CustomProgressDialog)? onCancelPressed;
  late BuildContext context;
  String progressMessage;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  CustomProgressDialog(this.future,
      {Key? key, required this.progressMessage, this.onCancelPressed})
      : super(key: key);

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Widget build(BuildContext context) {
    future.then((value) {
      Navigator.of(context).pop(value);
    }).catchError((e) {
      Navigator.of(context).pop();
    });

    return WillPopScope(
        child: _buildDialog(context),
        onWillPop: () {
          return Future(() {
            return false;
          });
        });
  }

  Widget _buildDialog(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.all(Radius.circular(values.borderRadius))),
              child: Wrap(alignment: WrapAlignment.center, children: [
                Container(
                    margin: const EdgeInsets.only(top: 30, bottom: 10),
                    height: 50,
                    width: 50,
                    child: const CircularProgressIndicator(
                      color: custom_colors.black,
                    )),
                Container(
                    margin: const EdgeInsets.all(0),
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, bottom: 25, top: 25),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        progressMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    )),
                CustomButton(
                    text: AppLocalizations.of(context)!.cancel,
                    defaultBackground: custom_colors.blackGradient,
                    textColor: Colors.white,
                    fontWeight: FontWeight.bold,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(values.borderRadius),
                        bottomRight: Radius.circular(values.borderRadius)),
                    showBorder: false,
                    onPressed: () => {
                          if (onCancelPressed != null) {onCancelPressed!(this)}
                        })
              ])),
        ));
  }

//endregion

}
