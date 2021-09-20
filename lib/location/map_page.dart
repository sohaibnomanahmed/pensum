import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leaf/localization/localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import 'map_provider.dart';

class MapPage extends StatefulWidget {
  final bool isSelecting;
  final LatLng? storedLocation;

  MapPage({this.isSelecting = false, this.storedLocation});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    context.read<MapProvider>().getCurrentUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    final loc = Localization.of(context);
    final isLoading = context.watch<MapProvider>().isLoading;
    final initialLocation = context.watch<MapProvider>().initialLocation;
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.storedLocation ?? initialLocation ?? const LatLng(59.93998545262962, 10.721642310303144),
                zoom: 13,
              ),
              onTap: widget.isSelecting
                  ? (LatLng position) => setState(() {
                        _currentPosition = position;
                      })
                  : null,
              markers: (_currentPosition == null && widget.storedLocation == null && initialLocation == null && widget.isSelecting)
                  ? {}
                  : {
                      Marker(
                          markerId: MarkerId('m1'),
                          position: widget.storedLocation ?? _currentPosition ?? initialLocation!)
                    },
            ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            mini: true,
            elevation: 0,
            backgroundColor: Colors.blueGrey,
            child: Icon(Icons.clear),
          ),
          SizedBox(width: 20),
          if ((_currentPosition != null || initialLocation != null) && widget.isSelecting)
            FloatingActionButton.extended(
              elevation: 0,
              onPressed: () => Navigator.of(context).pop(_currentPosition),
              label: Text(loc.getTranslatedValue('send_location_btn_text')),
              icon: Icon(Icons.location_on_rounded),
              backgroundColor: Colors.blueGrey,
            ),
          if (!widget.isSelecting)
            FloatingActionButton.extended(
              elevation: 0,
              onPressed: () async {
                // Here we are supplying the variables that we've created above
                final lat = widget.storedLocation!.latitude;
                final lng = widget.storedLocation!.longitude;
                // final googleMapsUrl = 'comgooglemaps://?center=$lat,$lng';
                // final appleMapsUrl = 'https://maps.apple.com/?q=$lat,$lng';

                // if (await canLaunch(googleMapsUrl)) {
                //   await launch(googleMapsUrl);
                // }
                // if (await canLaunch(appleMapsUrl)) {
                //   await launch(appleMapsUrl, forceSafariVC: false);
                // }
                final url =
                    'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw "Couldn't launch URL";
                }
              },
              label:
                  Text(loc.getTranslatedValue('open_in_google_maps_btn_text')),
              icon: Icon(Icons.location_on_rounded),
            )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
