import 'package:flutter/material.dart';
import 'package:leaf/global/functions.dart';
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
    return SafeArea(
      child: SingleChildScrollView(
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
                  onSaved: (value) => _firstname = value /*!*/,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Lastname'),
                  validator: (value) =>
                      (value.isEmpty) ? 'Please enter a lastname' : null,
                  onSaved: (value) => _lastname = value /*!*/,
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) => (value.isEmpty || !value.contains('@'))
                      ? 'Please enter a valid email address.'
                      : null,
                  onSaved: (value) => _email = value /*!*/,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => (value.isEmpty || value.length < 7)
                      ? 'Password must be at least 7 characters long.'
                      : null,
                  onSaved: (value) => _password = value /*!*/,
                ),
                SizedBox(height: 10),
                // This diviate from the typical ButtonFunctions.onPressHandler
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
                            await ButtonFunctions.onPressHandler(
                              context: context,
                              action: () async => await context
                                  .read<AuthenticationProvider>()
                                  .createUser(
                                      firstname: _firstname,
                                      lastname: _lastname,
                                      email: _email,
                                      password: _password),
                              popScreenAfter: true,
                              lateErrorMessage: () => context
                                  .read<AuthenticationProvider>()
                                  .errorMessage,
                              successMessage:
                                  'Sent email verification, please check your inbox',
                            );
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        )
                      : Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}