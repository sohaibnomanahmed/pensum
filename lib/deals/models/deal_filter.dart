import 'package:flutter/foundation.dart';

class DealFilter {
  int priceAbove;
  int priceBelow;
  List<String> places;
  String quality;

  DealFilter({
    @required this.priceAbove,
    @required this.priceBelow,
    @required this.places,
    @required this.quality,
  });

  DealFilter.empty();

  bool get isEmpty {
    if ((priceBelow == null) ||
        (priceAbove == null) ||
        (places == null) ||
        (quality == null)) {
      return true;
    }
    return false;
  }
}
