const priceDivisions = 50;

List<String> get prices {
  final priceValues = ['Gratis'];
  for (var i = 50; i < 3050; i += priceDivisions) {
    priceValues.add(i.toString() + ' kr');
  }
  return priceValues;
}
