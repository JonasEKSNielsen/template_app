import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

abstract class GeneralUtil {

  /// Hide keyboard
  static void hideKeyboard() {
    FocusManager.instance.primaryFocus!.unfocus();
  }

  /// Go to next page and close the previous
  /// [context] is the context doing the navigation
  /// [page] is the page being navigated to
  /// [goBack] is a flag deciding how the navigation animation is done
  static Future<void> goToPage(
    BuildContext context,
    Widget page,
    {
      bool goBack = false,
      bool doTransition = true,
      bool rootNavigator = true,
      NavigatorState? navigatorState,
    }
  ) async {
    navigatorState ??= Navigator.of(context, rootNavigator: rootNavigator);

    if (doTransition) {
      await navigatorState.pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, anotherAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, anotherAnimation, child) => SlideTransition(
            textDirection: goBack ? TextDirection.rtl : TextDirection.ltr,
            position: Tween(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
      );
    } else {
      await navigatorState.pushReplacement(PageRouteBuilder(pageBuilder: (context, animation, anotherAnimation) => page));
    }
  }

  /// Show a toast to the user
  /// [message] is the message to be displayed
  static void showToast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
  }
}
