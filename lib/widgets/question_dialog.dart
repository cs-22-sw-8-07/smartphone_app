import 'package:flutter/material.dart';
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/values/values.dart' as values;

enum DialogQuestionResponse { yes, no }

// ignore: must_be_immutable
class QuestionDialog extends StatelessWidget {
  ///
  /// STATICS
  ///
  //region Statics

  static Future<DialogQuestionResponse> show(
      {required BuildContext context, required String question}) async {
    return await Future.delayed(Duration.zero, () async {
      // Show dialog
      return await showDialog(
          context: context,
          builder: (context) => QuestionDialog._(question: question),
          barrierDismissible: false);
    });
  }

  //endregion

  ///
  /// VARIABLES
  ///
  //region Variables

  String question;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  // ignore: prefer_const_constructors_in_immutables
  QuestionDialog._({Key? key, required this.question}) : super(key: key);

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Widget build(BuildContext context) {
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
                    margin: const EdgeInsets.all(0),
                    padding: const EdgeInsets.only(
                        left: values.padding,
                        right: values.padding,
                        bottom: 25,
                        top: 25),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    )),
                Container(
                  height: 1,
                  color: Colors.white,
                ),
                Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                              text: AppLocalizations.of(context)!.no,
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                              ),
                              textColor: Colors.white,
                              fontWeight: FontWeight.bold,
                              borderRadius: const BorderRadius.only(
                                  bottomLeft:
                                      Radius.circular(values.borderRadius)),
                              showBorder: false,
                              onPressed: () async {
                                Navigator.of(context)
                                    .pop(DialogQuestionResponse.no);
                              }),
                        ),
                        Container(
                          width: 2,
                          color: Colors.transparent,
                        ),
                        Expanded(
                          child: CustomButton(
                              text: AppLocalizations.of(context)!.yes,
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              textColor: Colors.white,
                              fontWeight: FontWeight.bold,
                              borderRadius: const BorderRadius.only(
                                  bottomRight:
                                      Radius.circular(values.borderRadius)),
                              showBorder: false,
                              onPressed: () async {
                                Navigator.of(context)
                                    .pop(DialogQuestionResponse.yes);
                              }),
                        )
                      ],
                    ))
              ])),
        ));
  }

//endregion
}
