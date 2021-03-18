import 'package:flutter/material.dart';
import 'package:leaf/authentication/widgets/reset_password_bottom_sheet.dart';
import 'package:provider/provider.dart';

import 'package:leaf/authentication/authentication_provider.dart';

import 'delete_account_bottom_sheet.dart';

class SettingsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthenticationProvider>().isLoading;
    return SingleChildScrollView(
      child: Column(
        children: [
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
            onTap: () {
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //       behavior: SnackBarBehavior.floating,
              //       backgroundColor: Theme.of(context).canvasColor,
              //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              //       content: ListTile(
              //         contentPadding: EdgeInsets.all(0),
              //         dense: true,
              //         leading: CircleAvatar(
              //             backgroundImage: NetworkImage(
              //                 'https://firebasestorage.googleapis.com/v0/b/leaf-e52aa.appspot.com/o/profile.png?alt=media&token=ef36af4e-c528-4851-b429-53f867672b33')),
              //         title: Text('tony'),
              //         subtitle: Text('a long message if you want'),
              //         onTap: () {
              //           ScaffoldMessenger.of(context).hideCurrentSnackBar();
              //         },
              //       )),
              // );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app_rounded),
            title: Text('Sign out'),
            onTap: isLoading
                ? null
                : () async {
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
          ),
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
