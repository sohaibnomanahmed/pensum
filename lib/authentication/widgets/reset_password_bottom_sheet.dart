import 'package:flutter/material.dart';
import 'package:leaf/global/functions.dart';
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
                  decoration: InputDecoration(labelText: 'Email'),
                  onChanged: (val) => _email = val),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: (_email.isEmpty || isLoading)
                    ? null
                    : () async => ButtonFunctions.onPressHandler(
                          context: context,
                          action: () => context
                              .read<AuthenticationProvider>()
                              .resetPassword(_email),
                          // TODO post null safety does late work here for lazy work?
                          lateErrorMessage: () => context
                              .read<AuthenticationProvider>()
                              .errorMessage,
                          popScreenAfter: true,
                          successMessage:
                              'Reset password email sent, please check your inbox',
                        ),
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
