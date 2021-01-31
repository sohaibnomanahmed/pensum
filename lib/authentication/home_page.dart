import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leaf/authentication/authentication_provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: TextButton(
          onPressed: () async {
            var result = await context.read<AuthenticationProvider>().signOut();
            if (!result) {
              // remove snackbar if existing and show a new with error message
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              scaffoldMessenger.hideCurrentSnackBar();
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).errorColor,
                  content: Text(
                    context.read<AuthenticationProvider>().errorMessage,
                  ),
                ),
              );
            }
          },
          child: Text('Sign out'),
        ),
      ),
    );
  }
}
