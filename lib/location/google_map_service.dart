import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GoogleMapService {
  /// generate location preview image
  String generateLocationPreviewImage({@required double latitude, @required double longitude}){
    const GOOGLE_API_KEY = 'AIzaSyASyQrD1FCJEmrPvrcLUWeGcn2pubkqFy8';
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }

  /// get address of a location, if not found return a empty string
  Future<String> getPlaceAddress({@required double latitude, @required double longitude}) async {
    const GOOGLE_API_KEY = 'AIzaSyASyQrD1FCJEmrPvrcLUWeGcn2pubkqFy8';
    final image = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$GOOGLE_API_KEY';
    final url = Uri.parse(image);
    final response = await http.get(url);
    final address = jsonDecode(response.body)['results'][0]['formatted_address'] ?? '';
    return address;
  }
}