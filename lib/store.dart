import 'package:flutter/foundation.dart';

import 'catalog.dart';
import 'models.dart';

class PerfumeStore extends ChangeNotifier {
  PerfumeStore() : _products = List<PerfumeProduct>.of(defaultProducts);

  List<PerfumeProduct> _products;

  List<PerfumeProduct> get products => List.unmodifiable(_products);

  PerfumeProduct? byId(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  void add(PerfumeProduct product) {
    _products = [product, ..._products];
    notifyListeners();
  }

  void update(PerfumeProduct product) {
    _products = [
      for (final existing in _products)
        if (existing.id == product.id) product else existing,
    ];
    notifyListeners();
  }

  void delete(String id) {
    _products = _products.where((product) => product.id != id).toList();
    notifyListeners();
  }

  void reset() {
    _products = List<PerfumeProduct>.of(defaultProducts);
    notifyListeners();
  }
}
