import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smartphone_app/values/values.dart';

enum PermissionState { granted, denied }

class GeneralUtil {
  /// Set editing controller text
  /// Set [text] for a given [textEditingController]
  static setTextEditingControllerText(
      TextEditingController textEditingController, String? text) {
    text = text ?? "";
    if (textEditingController.value.text == text) return;
    textEditingController.value = TextEditingValue(
      text: text,
      selection: TextSelection.fromPosition(
        TextPosition(offset: text.length),
      ),
    );
  }

  /// Hide keyboard
  static hideKeyboard() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    FocusManager.instance.primaryFocus!.unfocus();
  }

  /// Go to next page and close the previous
  /// [context] is the context doing the navigation
  /// [page] is the page being navigated to
  /// [goBack] is a flag deciding how the navigation animation is done
  static goToPage(BuildContext context, Widget page,
      {bool goBack = false}) async {
    await Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation, anotherAnimation) {
              return page;
            },
            transitionDuration:
                const Duration(milliseconds: pageTransitionTime),
            transitionsBuilder: (context, animation, anotherAnimation, child) {
              return SlideTransition(
                textDirection: goBack ? TextDirection.rtl : TextDirection.ltr,
                position: Tween(
                        begin: const Offset(1.0, 0.0),
                        end: const Offset(0.0, 0.0))
                    .animate(animation),
                child: child,
              );
            }));
  }

  /// Go to next page and close the previous
  /// [context] is the context doing the navigation
  /// [page] is the page being navigated to
  /// [goBack] is a flag deciding how the navigation animation is done
  static showPopup(BuildContext context, Widget page) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
          pageBuilder: (context, animation, anotherAnimation) {
            return page;
          },
          transitionDuration: const Duration(milliseconds: pageTransitionTime),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            return SlideTransition(
              position: Tween(
                      begin: const Offset(0.0, 1.0),
                      end: const Offset(0.0, 0.0))
                  .animate(animation),
              child: child,
            );
          }),
    );
  }

  static showPageAsDialog<T>(BuildContext context, Widget page) async {
    return await showGeneralDialog<T>(
        context: context,
        barrierDismissible: false,
        pageBuilder: (context, animation, anotherAnimation) {
          return page;
        },
        transitionDuration: const Duration(milliseconds: pageTransitionTime),
        transitionBuilder: (context, animation, anotherAnimation, child) {
          return SlideTransition(
            position: Tween(
                    begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0))
                .animate(animation),
            child: child,
          );
        });
  }

  /// Show a toast to the user
  /// [message] is the string shown to the user
  static showToast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
  }

  /// Check for a internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final response = await InternetAddress.lookup('www.google.com');
      if (response.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
}
