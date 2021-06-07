import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  final String? id;
  final String sid; // sender id
  final String text;
  final Timestamp time;
  final String type;
  bool seen;
  late bool isMe;

  Message({
    required this.sid,
    required this.text,
    required this.time,
    required this.type,
    required this.seen,
    this.id,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw 'Error creating Message from null value';
    }
    // non null-able fields
    final String? text = data['text'];
    final String? sid = data['sid'];
    final String? type = data['type'];
    final bool? seen = data['seen'];
    final Timestamp? time = data['time'];
    // non able fields
    final String? image = data['image'];
    final String? address = data['address'];
    final double? latitude = data['latitude'];
    final double? longitude = data['longitude'];

    if (sid == null ||
        time == null ||
        type == null ||
        seen == null ||
        text == null) {
      throw 'Error creating Message from null value';
    }

    if (type == 'image') {
      if (image == null) {
      throw 'Error creating Image Message from null value';
    }
      return ImageMessage(
          sid: sid,
          text: text,
          image: image,
          time: time,
          type: type,
          seen: seen,
          id: doc.id);
    } else if (type == 'location') {
      if (image == null ||
        latitude == null ||
        longitude == null ||
        address == null
        ){
      throw 'Error creating Location Message from null value';
    }
      return LocationMessage(
          sid: sid,
          text: text,
          image: image,
          address: address,
          latitude: latitude,
          longitude: longitude,
          time: time,
          type: type,
          seen: seen,
          id: doc.id);
    } else {
      return Message(
          text: text, sid: sid, time: time, type: type, seen: seen, id: doc.id);
    }
  }

  @override
  String toString(){
    return text;
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'time': time,
      'sid': sid,
      'type': type,
      'seen': seen,
    };
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(covariant Message other) => other.id == id;
}

class LocationMessage extends Message {
  final String address;
  final double latitude;
  final double longitude;
  final String image;

  LocationMessage(
      {required sid,
      required text,
      required time,
      required type,
      required seen,
      required this.image,
      required this.address,
      required this.latitude,
      required this.longitude,
      id})
      : super(sid: sid, seen: seen, text: text, time: time, type: type, id: id);

  @override
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'time': time,
      'sid': sid,
      'image': image,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'seen': seen,
    };
  }
}

class ImageMessage extends Message {
  final String image;

  ImageMessage(
      {required sid,
      required text,
      required time,
      required type,
      required seen,
      required this.image,
      id})
      : super(sid: sid, seen: seen, text: text, time: time, type: type, id: id);

  @override
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'time': time,
      'sid': sid,
      'image': image,
      'type': type,
      'seen': seen,
    };
  }
}
