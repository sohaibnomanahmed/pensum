import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../authentication/authentication_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthenticationProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: isLoading ? null : () async {
              var result =
                  await context.read<AuthenticationProvider>().signOut();
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
            icon: Icon(Icons.exit_to_app),
          ),
          IconButton(
            onPressed: isLoading ? null : () async {
              print('start');
              var result = await context
                  .read<AuthenticationProvider>()
                  .deleteUser('1234567'); 
              // TODO gets error if user id deleted and try to delete again, 
              // he will be logged out and context cnat be found
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
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator()) : Text('Settings'),
    );
  }
}
