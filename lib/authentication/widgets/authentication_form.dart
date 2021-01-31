import 'package:flutter/material.dart';
import 'package:leaf/authentication/authentication_provider.dart';
import 'package:provider/provider.dart';

class AuthenticationForm extends StatefulWidget {
  @override
  _AuthenticationFormState createState() => _AuthenticationFormState();
}

class _AuthenticationFormState extends State<AuthenticationForm> {
  final _formKey = GlobalKey<FormState>();
  String _email;
  String _password;

  @override
  Widget build(BuildContext context) {
    var isLoading = context.watch<AuthenticationProvider>().isLoading;
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
                isDense: true,
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.grey[200]),
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
                isDense: true,
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.grey[200]),
            obscureText: true,
            validator: (value) => (value.isEmpty || value.length < 7)
                ? 'Password must be at least 7 characters long.'
                : null,
            onSaved: (value) => _password = value,
          ),
          Container(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () {}, child: Text('Forgot password')),
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
                      var result =
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
          TextButton(onPressed: () {}, child: Text('Already have an account'))
        ],
      ),
    );
  }
}
