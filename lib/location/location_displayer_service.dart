class LocationDisplayer {
  // generate location preview image
  String generateLocationPreviewImage({double latitude, double longitude}){
    const GOOGLE_API_KEY = 'AIzaSyASyQrD1FCJEmrPvrcLUWeGcn2pubkqFy8';
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }
}