import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leaf/location/map_page.dart';
import 'package:leaf/messages/models/message.dart';

class LocationImageItem extends StatelessWidget {
  final LocationMessage message;

  LocationImageItem(this.message);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedColor: Colors.transparent,
      closedElevation: 0,
      openBuilder: (_, __) => MapPage(
        storedLocation: LatLng(message.latitude, message.longitude),
      ),
      closedBuilder: (_, __) => Image.network(
        message.image,
        height: 130,
        gaplessPlayback: true,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 130,
            color: Theme.of(context).splashColor,
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            Icons.wifi_off_rounded,
            size: 60,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ),
    );
  }
}
