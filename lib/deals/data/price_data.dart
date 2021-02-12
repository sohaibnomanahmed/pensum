List<String> get prices {
  final priceValues = ['Gratis'];
  for (var i = 50; i < 3050; i += 50) {
    priceValues.add(i.toString() + ' kr');
  }
  return priceValues;
}
