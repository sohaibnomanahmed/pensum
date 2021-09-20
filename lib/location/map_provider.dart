import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapProvider with ChangeNotifier{
  LatLng? _initialLocation;
  //var _isError = false;
  var _isLoading = true;

  // getters
  LatLng? get initialLocation => _initialLocation;
  bool get isLoading => _isLoading;
  //bool get isError => _isError;

  /// get the current location of a user
  void getCurrentUserLocation() async {
    final location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    var locationData = await location.getLocation();
    _initialLocation = LatLng(locationData.latitude!, locationData.longitude!);
    _isLoading = false;
    notifyListeners();
  }
}