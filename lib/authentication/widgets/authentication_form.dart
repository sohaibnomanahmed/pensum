import 'package:flutter/material.dart';
import 'package:leaf/authentication/authentication_provider.dart';
import 'package:leaf/global/functions.dart';
import 'package:provider/provider.dart';

import 'create_account_bottom_sheet.dart';
import 'reset_password_bottom_sheet.dart';

class AuthenticationForm extends StatefulWidget {
  @override
  _AuthenticationFormState createState() => _AuthenticationFormState();
}

class _AuthenticationFormState extends State<AuthenticationForm> {
  final _formKey = GlobalKey<FormState>();
  var _email = '';
  var _password = '';

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthenticationProvider>().isLoading;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // email text field
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
            validator: (value) => (value.isEmpty || !value.contains('@'))
                ? 'Please enter a valid email address.'
                : null,
            onSaved: (value) => _email = value,
          ),
          SizedBox(
            height: 5,
          ),
          // password text field
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
            validator: (value) => (value.isEmpty || value.length < 7)
                ? 'Password must be at least 7 characters long.'
                : null,
            onSaved: (value) => _password = value,
          ),
          Container(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(5.0),
                    ),
                  ),
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => ResetPasswordBottomSheet(),
                );
              },
              child: Text('Forgot password'),
            ),
          ),
          // log in button
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    // validate form and sign the user in
                    final isValid = _formKey.currentState.validate();
                    if (isValid) {
                      FocusScope.of(context).unfocus();
                      // save values
                      _formKey.currentState.save();
                      // TODO nees async or await
                      await ButtonFunctions.onPressHandler(
                          context: context,
                          action: () async => await context
                              .read<AuthenticationProvider>()
                              .signIn(email: _email, password: _password),
                          lateErrorMessage: () => context
                              .read<AuthenticationProvider>()
                              .errorMessage);
                    }
                  },
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  )
                : Text('Log in'),
          ),
          // create account button
          TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(5.0),
                    ),
                  ),
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => CreateAccountBottomSheet(),
                );
              },
              child: Text('Create an account'))
        ],
      ),
    );
  }
}
