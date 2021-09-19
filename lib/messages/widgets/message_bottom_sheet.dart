import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leaf/localization/localization.dart';
import 'package:leaf/location/map_page.dart';
import 'package:provider/provider.dart';

import 'package:image_picker/image_picker.dart';
import 'package:leaf/messages/messages_provider.dart';

class MessageBottomSheet extends StatelessWidget {
  final String rid;
  final String receiverImage;
  final String receiverName;

  const MessageBottomSheet({
    required this.rid,
    required this.receiverName,
    required this.receiverImage,
  });

  Widget message_item_builder({
    required BuildContext context,
    required String text,
    required IconData icon,
    required void Function() action,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        onTap: action,
        child: Container(
          width: 90,
          padding: EdgeInsets.all(10),
          color: Theme.of(context).splashColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Theme.of(context).hintColor, size: 50),
              SizedBox(height: 5),
              Text(
                text,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = Localization.of(context);
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              message_item_builder(
                  context: context,
                  action: () {
                    Navigator.of(context).pop();
                    context.read<MessagesProvider>().sendImage(
                        source: ImageSource.camera,
                        rid: rid,
                        receiverName: receiverName,
                        receiverImage: receiverImage);
                  },
                  text: loc.getTranslatedValue('camera_action'),
                  icon: Icons.camera_rounded),
              SizedBox(
                width: 10,
              ),
              message_item_builder(
                  context: context,
                  action: () {
                    Navigator.of(context).pop();
                    context.read<MessagesProvider>().sendImage(
                        source: ImageSource.gallery,
                        rid: rid,
                        receiverName: receiverName,
                        receiverImage: receiverImage);
                  },
                  text: loc.getTranslatedValue('photo_library_action'),
                  icon: Icons.photo_rounded),
              SizedBox(
                width: 10,
              ),
              message_item_builder(
                  context: context,
                  action: () {
                    Navigator.of(context).pop();
                    context.read<MessagesProvider>().sendLocation(
                          currentLocation: true,
                          rid: rid,
                          receiverName: receiverName,
                          receiverImage: receiverImage,
                        );
                  },
                  text: loc.getTranslatedValue('current_location_action'),
                  icon: Icons.location_on_rounded),
              SizedBox(
                width: 10,
              ),
              message_item_builder(
                  context: context,
                  action: () async {
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
                  text: loc.getTranslatedValue('select_location_action'),
                  icon: Icons.map_rounded),
            ],
            // cancelButton: CupertinoActionSheetAction(
            //     onPressed: () {
            //       Navigator.of(context).pop();
            //     },
            //     child: Text(loc.getTranslatedValue('cancel_action'))),
          ),
        ),
      ),
    );
  }
}
