import 'package:flutter/material.dart';
import 'package:leaf/global/utils.dart';
import 'package:leaf/localization/localization.dart';
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
    final loc = Localization.of(context);
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
                  decoration: InputDecoration(labelText: loc.getTranslatedValue('reset_pass_email_hint')),
                  onChanged: (val) => _email = val),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: (isLoading)
                    ? null
                    : () async => onPressHandler(
                          context: context,
                          action: () => context
                              .read<AuthenticationProvider>()
                              .resetPassword(_email),
                          lateErrorMessage: () => context
                              .read<AuthenticationProvider>()
                              .errorMessage,
                          popScreenAfter: true,
                          successMessage:
                              loc.getTranslatedValue('reset_pass_success_msg_text'),
                        ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text(loc.getTranslatedValue('reset_pass_send_btn_text')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
