/// [DealFilter] contains nullable values as [places] can be empty and contain a place and
/// the method [isEmpty] should be false, this can only happen is null is allowed. Since at
/// every filtering all the values get updated and on clearing all gets null which can be
/// cheked by [isEmpty] it should be avoidable to access a null value.
class DealFilter {
  int? priceAbove;
  int? priceBelow;
  List<String>? places;
  String? quality;

  DealFilter({
    required this.priceAbove,
    required this.priceBelow,
    required this.places,
    required this.quality,
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
