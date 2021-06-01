import 'package:flutter/material.dart';

class ButtonFunctions {
  static Future<void> onPressHandler({
    @required BuildContext context,
    @required Future<bool> Function() action,
    bool popScreen = false,
    String errorMessage,
    String successMessage,
  }) async {
    // store variables that might not be avaiable later
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).errorColor;
    final primaryColor = Theme.of(context).primaryColor;

    // pop screen
    if (popScreen) {
      Navigator.of(context).pop();
    }

    // do some action
    final result = await action();

    // check if an error occured, only if a error message is provided
    if (!result && errorMessage.isNotEmpty) {
      // remove snackbar if existing and show a new with error message
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: errorColor,
          content: Text(errorMessage),
        ),
      );
    }
    if (result && successMessage.isNotEmpty) {
      // remove snackbar if existing and show a new with error message
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: primaryColor,
          content: Text(successMessage),
        ),
      );
    }
  }
}
