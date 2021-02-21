import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../authentication_provider.dart';

class CreateAccountBottomSheet extends StatefulWidget {
  @override
  _CreateAccountBottomSheetState createState() =>
      _CreateAccountBottomSheetState();
}

class _CreateAccountBottomSheetState extends State<CreateAccountBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  var _email = '';
  var _password = '';
  var _firstname = '';
  var _lastname = '';

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthenticationProvider>().isLoading;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
              Icon(
                Icons.laptop_mac,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Firstname'),
                validator: (value) =>
                    (value.isEmpty) ? 'Please enter a firstname.' : null,
                onSaved: (value) => _firstname = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Lastname'),
                validator: (value) =>
                    (value.isEmpty) ? 'Please enter a lastname' : null,
                onSaved: (value) => _lastname = value,
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => (value.isEmpty || !value.contains('@'))
                    ? 'Please enter a valid email address.'
                    : null,
                onSaved: (value) => _email = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => (value.isEmpty || value.length < 7)
                    ? 'Password must be at least 7 characters long.'
                    : null,
                onSaved: (value) => _password = value,
              ),
              SizedBox(height: 10),
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
                          final result = await context
                              .read<AuthenticationProvider>()
                              .createUser(
                                firstname: _firstname.trim().toLowerCase(),
                                lastname: _lastname.trim().toLowerCase(),
                                email: _email,
                                password: _password,
                              );
                          // pop bottom sheet
                          Navigator.of(context).pop();
                          // check if an error occured
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);
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
                                    'Sent email verification, please check your inbox'),
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
                    : Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
