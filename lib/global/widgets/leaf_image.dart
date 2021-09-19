import 'package:flutter/material.dart';

class LeafImage extends StatelessWidget {
  final String text;
  final String assetImage;

  const LeafImage({Key? key, this.text = '', required this.assetImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(assetImage, width: 300,),
            SizedBox(height: 20),
            Text(text)
          ],
        ),
      ),
    );
  }
}
