import 'package:flutter/material.dart';
import 'package:leaf/authentication/authentication_provider.dart';
import 'package:provider/provider.dart';

import 'create_account_bottom_sheet.dart';
import 'forgot_password_bottom_sheet.dart';

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
                  builder: (_) => ForgotPasswordBottomSheet(),
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
                      final result =
                          await context.read<AuthenticationProvider>().signIn(
                                email: _email,
                                password: _password,
                              );
                      // check if an error occured
                      if (!result) {
                        // remove snackbar if existing and show a new with error message
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
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
                    }
                  },
            child: isLoading
                ? SizedBox(
                    child: CircularProgressIndicator(),
                    height: 20,
                    width: 20,
                  )
                : Text('Log in'),
          ),
          // create account button
          TextButton(onPressed: () {
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
          }, child: Text('Create an account'))
        ],
      ),
    );
  }
}
