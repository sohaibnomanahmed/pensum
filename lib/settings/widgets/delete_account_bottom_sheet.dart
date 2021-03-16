import 'package:flutter/material.dart';
import 'package:leaf/authentication/authentication_provider.dart';
import 'package:provider/provider.dart';

class DeleteAccountBottomSheet extends StatefulWidget {
  @override
  _DeleteAccountBottomSheetState createState() =>
      _DeleteAccountBottomSheetState();
}

class _DeleteAccountBottomSheetState extends State<DeleteAccountBottomSheet> {
  var _password = '';

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthenticationProvider>().isLoading;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.delete_forever_rounded,
              size: 50,
              color: Theme.of(context).errorColor,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).splashColor,
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.all(16),
              child: Text(
                'By permanently deleting your account all data will be removed and can not be restored. Only delete your account if you are sure you wont need the data stored later!',
                textAlign: TextAlign.center,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
              onChanged: (val) {
                setState(() {
                  _password = val;
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: (_password.isEmpty || isLoading)
                  ? null
                  : () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final errorColor = Theme.of(context).errorColor;
                      final primaryColor = Theme.of(context).primaryColor;
                      final result = await context
                          .read<AuthenticationProvider>()
                          .deleteUser(_password);
                      // pop bottom sheet
                      Navigator.of(context).pop();
                      // show result message
                      if (!result) {
                        // remove snackbar if existing and show a new with error message
                        scaffoldMessenger.hideCurrentSnackBar();
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            backgroundColor: errorColor,
                            content: Text(
                                'Error occured while trying to delete account'),
                          ),
                        );
                      }
                      if (result) {
                        // remove snackbar if existing and show a new with error message
                        scaffoldMessenger.hideCurrentSnackBar();
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            backgroundColor: primaryColor,
                            content: Text('Successfully deleted account'),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).errorColor),
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
