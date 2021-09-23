import 'package:flutter/material.dart';
import 'package:leaf/global/utils.dart';
import 'package:leaf/localization/localization.dart';
import 'package:provider/provider.dart';

import '../authentication_provider.dart';

class CreateAccountBottomSheet extends StatefulWidget {
  final String pre_email;
  final String pre_pass;

  CreateAccountBottomSheet({required this.pre_email, required this.pre_pass});

  @override
  _CreateAccountBottomSheetState createState() =>
      _CreateAccountBottomSheetState();
}

class _CreateAccountBottomSheetState extends State<CreateAccountBottomSheet> {
  var _email = '';
  var _password = '';
  var _firstname = '';
  var _lastname = '';

  @override
    void initState() {
      super.initState();
      _email = widget.pre_email;
      _password = widget.pre_pass;
    }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthenticationProvider>().isLoading;
    final loc = Localization.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close,
                      color: Theme.of(context).primaryColorDark),
                ),
              ),
              Icon(
                Icons.laptop_mac,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              TextField(
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: loc.getTranslatedValue('reg_firstname_hint')),
                onChanged: (value) => _firstname = value,
              ),
              TextField(
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: loc.getTranslatedValue('reg_lastname_hint')),
                onChanged: (value) => _lastname = value,
              ),
              TextFormField(
                initialValue: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: loc.getTranslatedValue('reg_email_hint')),
                onChanged: (value) => _email = value,
              ),
              TextFormField(
                initialValue: _password,
                decoration: InputDecoration(labelText: loc.getTranslatedValue('reg_password_hint')),
                obscureText: true,
                onChanged: (value) => _password = value,
              ),
              SizedBox(height: 10),
              // This diviate from the typical ButtonFunctions.onPressHandler
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        // remove softkeayboard
                        FocusScope.of(context).unfocus();
                        await onPressHandler(
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
                              loc.getTranslatedValue('reg_success_msg_text'),
                        );
                      },
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text(loc.getTranslatedValue('reg_btn_text')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
