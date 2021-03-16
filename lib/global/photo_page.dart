import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoPage extends StatelessWidget {
  static const routeName = '/photo';
  final String imageUrl;

  PhotoPage(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PhotoView(
            imageProvider: NetworkImage(imageUrl),
            errorBuilder: (_, __, ___) => Icon(Icons.wifi_off_rounded),
          ),
          MaterialButton(
            color: Colors.black45,
            elevation: 0,
            onPressed: () => Navigator.pop(context),
            shape: CircleBorder(),
            child: Icon(Icons.clear, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
