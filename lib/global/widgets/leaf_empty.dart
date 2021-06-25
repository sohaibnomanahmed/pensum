import 'package:flutter/material.dart';

class LeafEmpty extends StatelessWidget {
  final String text;

  const LeafEmpty({Key? key, this.text = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/empty_box.png'),
            SizedBox(height: 20),
            Text(text)
          ],
        ),
      ),
    );
  }
}
