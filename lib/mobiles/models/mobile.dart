import 'package:cloud_firestore/cloud_firestore.dart';

class Mobile {
  final String colors;
  final String brand;
  final String model;
  final String processor;
  final String ram;
  final String resolution;
  final String screenSize;
  final String imageUrl;
  final String rearCamera;
  final String frontCamera;
  final int deals;
  final int followings; // number of deals for this book

  Mobile(
      {required this.colors,
      required this.brand,
      required this.model,
      required this.processor,
      required this.ram,
      required this.resolution,
      required this.screenSize,
      required this.imageUrl,
      required this.rearCamera,
      required this.frontCamera,
      required this.deals,
      required this.followings,
      });

  factory Mobile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw 'Error creating Mobile from null';
    }
    final String? brand = data['brand'];
    final String? model = data['model'];
    final String? colors = data['colors'];
    final String? imageUrl = data['imageUrl'];
    final String? processor = data['processor'];
    final String? ram = data['ram'];
    final String? resolution = data['resolution'];
    final String? screenSize = data['screenSize'];
    final String? rearCamera = data['rearCamera'];
    final String? frontCamera = data['frontCamera'];
    final int? deals = data['deals'];
    final int? followings = data['followings'];

    if (brand == null ||
        model == null ||
        colors == null ||
        imageUrl == null ||
        processor == null ||
        ram == null ||
        resolution == null ||
        screenSize == null ||
        rearCamera == null ||
        frontCamera == null ||
        deals == null ||
        followings == null) {
      throw 'Error creating Mobile from null value';
    }

    return Mobile(
      brand: brand,
      model: model,
        colors: colors,
        imageUrl: imageUrl,
        processor: processor,
        ram: ram,
        resolution: resolution,
        screenSize: screenSize,
        rearCamera: rearCamera,
        frontCamera: frontCamera,
        deals: deals,
        followings: followings,
    );
  }

  // // TODO need to be reversed string to list, not list to string!
  // String get getColors {
  //   var res = '';
  //   colors.forEach((author) {
  //     if (author == colors.last) {
  //       res += author;
  //     } else {
  //       res += author + ', ';
  //     }
  //   });
  //   return res;
  // }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'title': titles,
  //     'colors': colors,
  //     'imageUrl': imageUrl,
  //     'processor': processor,
  //     'ram': ram,
  //     'resolution': resolution,
  //     'screenSize': screenSize,
  //     'rearCamera': rearCamera,
  //     'isbn': isbn,
  //     'deals': deals,
  //     'followings': followings,
  //   };
  // }
}
