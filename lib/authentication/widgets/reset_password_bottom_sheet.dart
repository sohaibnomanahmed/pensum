import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../authentication_provider.dart';

class ResetPasswordBottomSheet extends StatefulWidget {
  @override
  _ResetPasswordBottomSheetState createState() =>
      _ResetPasswordBottomSheetState();
}

class _ResetPasswordBottomSheetState extends State<ResetPasswordBottomSheet> {
  var _email = '';

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthenticationProvider>().isLoading;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_open,
                size: 50,
                color: Theme.of(context).primaryColor,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                onChanged: (val) {
                  setState(() {
                    _email = val;
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: (_email.isEmpty || isLoading)
                    ? null
                    : () async {
                        final result = await context
                            .read<AuthenticationProvider>()
                            .resetPassword(_email);
                        // pop bottom sheet
                        Navigator.of(context).pop();
                        // show result message
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        if (!result) {
                          // remove snackbar if existing and show a new with error message
                          scaffoldMessenger.hideCurrentSnackBar();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              backgroundColor: Theme.of(context).errorColor,
                              content: Text(
                                context
                                    .read<AuthenticationProvider>()
                                    .errorMessage,
                              ),
                            ),
                          );
                        }
                        if (result) {
                          // remove snackbar if existing and show a new with error message
                          scaffoldMessenger.hideCurrentSnackBar();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              backgroundColor: Theme.of(context).primaryColor,
                              content: Text(
                                  'Sent reset password email, please check your inbox'),
                            ),
                          );
                        }
                      },
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text('Send reset password email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
