import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:smartphone_app/values/values.dart';

enum PermissionState { granted, denied }

extension DateTimeExtension on DateTime {
  String nowNoSecondsAsString() {
    return intl.DateFormat('dd-MM-yyyy kk:mm').format(this);
  }
}

class GeneralUtil {
  /// Go to next page and close the previous
  /// [context] is the context doing the navigation
  /// [page] is the page being navigated to
  /// [goBack] is a flag deciding how the navigation animation is done
  static goToPage(BuildContext context, Widget page,
      {bool goBack = false}) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
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
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
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

  /// Show a given [page] as a dialog which comes from the bottom
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
  static showToast(String? message) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    if (message != null) {
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
    }
  }

  /// Show a snackbar to the user (A message popup in the bottom of the screen)
  /// [message] is the string shown to the user
  static showSnackBar(
      {required BuildContext context, required String message}) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          message,
          style: GoogleFonts.roboto(
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
        )));
  }
}
