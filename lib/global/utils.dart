import 'package:flutter/material.dart';

/// This method reduces biolerplate code for onPress handlers that needs
/// to show the user if the action succedded or failed. Needs [context] to
/// be able to show snackBar. [action] is usually a anonymous function that returns
/// the desired function, this is done so parameters for the desired function can be
/// given on method call. [popScreen] and [popScreenAfter] is usefule to remove a
/// bottomSheet or similar. Where the latter is used when you want to show a loading
/// spinner while proccessing the action, this also gives uppertunity to use the [lateErrorMessage]
/// function, that can extract the spesified error message from the provider
Future<void> onPressHandler({
  required BuildContext context,
  required Future<bool> Function() action,
  bool popScreen = false,
  bool popScreenAfter = false,
  Function? lateErrorMessage,
  String? errorMessage,
  String? successMessage,
}) async {
  // store variables that might not be avaiable later
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final errorColor = Theme.of(context).errorColor;
  final primaryColor = Theme.of(context).primaryColor;

  // pop screen
  if (popScreen) {
    Navigator.of(context).pop();
  }

  // do some action, try-catch is for multiple actions inside action if any fail return false
  var result = false;
  try {
    result = await action();
  } catch (error) {
    result = false;
  }

  // pop screen
  if (popScreenAfter) {
    Navigator.of(context).pop();
  }

  // check if an error occured, only if a error message is provided
  if (!result && (errorMessage != null || lateErrorMessage != null)) {
    if (lateErrorMessage != null) {
      // TODO translate from firebase
      errorMessage = lateErrorMessage();
    }
    // remove snackbar if existing and show a new with error message
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        backgroundColor: errorColor,
        content: Text(errorMessage!),
      ),
    );
  }
  if (result && successMessage != null) {
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

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final r = color.red, g = color.green, b = color.blue;

  for (var i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}
