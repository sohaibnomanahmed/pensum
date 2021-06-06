import 'package:flutter/material.dart';
import 'package:leaf/authentication/widgets/reset_password_bottom_sheet.dart';
import 'package:leaf/global/functions.dart';
import 'package:leaf/messages/messages_page.dart';
import 'package:provider/provider.dart';

import 'package:leaf/authentication/authentication_provider.dart';

import 'delete_account_bottom_sheet.dart';

class SettingsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthenticationProvider>().isLoading;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          // TODO just call method?
          ListTile(
            leading: Icon(Icons.lock_rounded),
            title: Text('Reset Password'),
            onTap: () => showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(5.0),
                ),
              ),
              context: context,
              isScrollControlled: true,
              builder: (_) => ResetPasswordBottomSheet(),
            ),
          ),
          ListTile(
            leading: Icon(Icons.feedback_rounded),
            title: Text('Send Feedback'),
            onTap: isLoading
                ? null
                : () async {
                    final serviceAccount = await context
                        .read<AuthenticationProvider>()
                        .getAdminAccount();
                    if (serviceAccount != null) {
                      await Navigator.of(context, rootNavigator: true)
                          .pushNamed(
                        MessagesPage.routeName,
                        arguments: {
                          'id': serviceAccount.uid,
                          'image': serviceAccount.imageUrl,
                          'name': serviceAccount.fullName
                        },
                      );
                    } else {
                      // remove snackbar if existing and show a new with error message
                      scaffoldMessenger.hideCurrentSnackBar();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(context).errorColor,
                          content: Text(
                            'Something went wrong trying to get the service Account!',
                          ),
                        ),
                      );
                    }
                  },
          ),
          ListTile(
              leading: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Icon(Icons.exit_to_app_rounded),
              title: Text('Sign out'),
              onTap: isLoading
                  ? null
                  : () async => ButtonFunctions.onPressHandler(
                      context: context,
                      action: () async => await context
                          .read<AuthenticationProvider>()
                          .signOut(),
                      errorMessage: 'Something went wrong, please try again')),
          ListTile(
            leading: Icon(Icons.delete_rounded),
            title: Text('Delete Account'),
            onTap: () => showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (_) => DeleteAccountBottomSheet(),
            ),
          ),
        ],
      ),
    );
  }
}
