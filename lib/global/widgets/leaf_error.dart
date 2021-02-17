import 'package:flutter/material.dart';

class LeafError extends StatelessWidget {
  final Function reload;

  LeafError(this.reload);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/robot.png', height: 200),
        SizedBox(height: 30),
        OutlinedButton.icon(
          onPressed: () => reload(),
          icon: Icon(Icons.refresh_rounded),
          label: Text('Try again'),
        )
      ],
    );
  }
}
