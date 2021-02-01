import 'package:flutter/material.dart';
import 'package:leaf/authentication/widgets/background/bezierContainer.dart';

import 'widgets/authentication_form.dart';

class AuthenticationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned(
              top: -height * .10,
              right: -width * .3,
              child: BezierContainer(),
            ),
            Container(
              height: height,
              // hack to make gesture detector work
              color: Colors.transparent,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: AuthenticationForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
