import 'package:flutter/material.dart';
import 'package:leaf/global/widgets/bezierContainer.dart';

import 'widgets/authentication_form.dart';

class AuthenticationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned(
              top: -BezierContainer.height * .10,
              right: -BezierContainer.width * .3,
              child: BezierContainer(Icon(
                Icons.eco,
                size: 100,
                color: Theme.of(context).primaryColorLight,
              )),
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
