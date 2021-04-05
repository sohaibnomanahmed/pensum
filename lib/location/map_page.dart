import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  final LatLng initialLocation;
  final bool isSelecting;

  MapPage(
      {this.initialLocation =
          const LatLng(59.93998545262962, 10.721642310303144),
      this.isSelecting = false});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng _currentPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation,
          zoom: 16,
        ),
        onTap: widget.isSelecting
            ? (LatLng position) {
                setState(() {
                  _currentPosition = position;
                });
              }
            : null,
        markers: (_currentPosition == null && widget.isSelecting)
            ? {}
            : {
                Marker(
                    markerId: MarkerId('m1'),
                    position: _currentPosition ?? widget.initialLocation)
              },
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            mini: true,
            backgroundColor: Colors.black54,
            child: Icon(Icons.clear),
          ),
          SizedBox(width: 20),
          if (_currentPosition != null)
            FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pop(_currentPosition),
              label: Text('Send Location'),
              icon: Icon(Icons.location_on_rounded),
              backgroundColor: Colors.deepOrange,
            ),
          if (!widget.isSelecting)
            FloatingActionButton.extended(
              onPressed: () async {
                // TODO some error cant launch canLaunch is failing
                // Here we are supplying the variables that we've created above
                final lat = widget.initialLocation.latitude;
                final lng = widget.initialLocation.longitude;
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
              label: Text('Open in Maps'),
              icon: Icon(Icons.location_on_rounded),
              backgroundColor: Colors.black54,
            )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
