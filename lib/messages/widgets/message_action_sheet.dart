import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leaf/location/map_page.dart';
import 'package:provider/provider.dart';

import 'package:image_picker/image_picker.dart';
import 'package:leaf/messages/messages_provider.dart';

class MessageActionSheet extends StatelessWidget {
  final String rid;
  final String receiverImage;
  final String receiverName;

  const MessageActionSheet({
    @required this.rid,
    @required this.receiverName,
    @required this.receiverImage,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<MessagesProvider>().sendImage(
                source: ImageSource.camera,
                rid: rid,
                receiverName: receiverName,
                receiverImage: receiverImage);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('Camera', overflow: TextOverflow.ellipsis)),
              Icon(Icons.camera_rounded, color: Theme.of(context).hintColor)
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<MessagesProvider>().sendImage(
                source: ImageSource.gallery,
                rid: rid,
                receiverName: receiverName,
                receiverImage: receiverImage);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child:
                      Text('Photo Library', overflow: TextOverflow.ellipsis)),
              Icon(Icons.photo_rounded, color: Theme.of(context).hintColor)
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<MessagesProvider>().sendLocation(
                  currentLocation: true,
                  rid: rid,
                  receiverName: receiverName,
                  receiverImage: receiverImage,
                );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text('Current Location',
                      overflow: TextOverflow.ellipsis)),
              Icon(Icons.location_on_rounded,
                  color: Theme.of(context).hintColor)
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () async {
            final selectedLocation =
                await Navigator.of(context, rootNavigator: true)
                    .push<LatLng>(MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (ctx) => MapPage(
                              isSelecting: true,
                            )));
            if (selectedLocation == null) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pop();
              await context.read<MessagesProvider>().sendLocation(
                    currentLocation: false,
                    rid: rid,
                    receiverName: receiverName,
                    receiverImage: receiverImage,
                    longitude: selectedLocation.longitude,
                    latitude: selectedLocation.latitude,
                  );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child:
                      Text('Select Location', overflow: TextOverflow.ellipsis)),
              Icon(Icons.map_rounded, color: Theme.of(context).hintColor)
            ],
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel')),
    );
  }
}
