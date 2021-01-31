import 'package:flutter/material.dart';

import 'widgets/authentication_form.dart';

class AuthenticationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: AuthenticationForm(),
          ),
        ),
      ),
    );
  }
}
