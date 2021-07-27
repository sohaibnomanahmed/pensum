import 'package:flutter/material.dart';
import 'package:leaf/authentication/authentication_provider.dart';
import 'package:leaf/global/utils.dart';
import 'package:provider/provider.dart';
import 'package:leaf/localization/localization.dart';

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
    final loc = Localization.of(context);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: loc.getTranslatedValue('auth_email_hint')),
            onChanged: (value) => _email = value,
          ),
          SizedBox(height: 5),
          TextField(
            decoration: InputDecoration(labelText: loc.getTranslatedValue('auth_password_hint')),
            obscureText: true,
            onChanged: (value) => _password = value,
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
              child: Text(loc.getTranslatedValue('reset_password_btn_text')),
            ),
          ),
          // log in button
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    // hide soft keayboard
                    FocusScope.of(context).unfocus();
                    await onPressHandler(
                        context: context,
                        action: () => context
                            .read<AuthenticationProvider>()
                            .signIn(email: _email, password: _password),
                        lateErrorMessage: () => context
                            .read<AuthenticationProvider>()
                            .errorMessage);
                  },
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  )
                : Text(loc.getTranslatedValue('login_btn_text')),
          ),
          // create account button
          TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(5.0))),
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => CreateAccountBottomSheet(),
                );
              },
              child: Text(loc.getTranslatedValue('register_btn_text')))
        ],
      ),
    );
  }
}
