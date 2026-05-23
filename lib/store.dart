import 'package:flutter/foundation.dart';

import 'catalog.dart';
import 'models.dart';

class PerfumeStore extends ChangeNotifier {
  PerfumeStore()
    : _products = List<PerfumeProduct>.of(defaultProducts),
      _noteOptions = defaultEditableNoteOptions();

  List<PerfumeProduct> _products;
  List<String> _noteOptions;

  List<PerfumeProduct> get products => List.unmodifiable(_products);

  List<String> get noteOptions => List.unmodifiable(_noteOptions);

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

  bool addNote(String note) {
    final cleaned = _cleanNote(note);
    if (cleaned.isEmpty || _containsNote(cleaned)) return false;

    _noteOptions = _sortNotes([..._noteOptions, cleaned]);
    notifyListeners();
    return true;
  }

  bool renameNote(String currentNote, String nextNote) {
    final current = _cleanNote(currentNote);
    final next = _cleanNote(nextNote);
    if (current.isEmpty || next.isEmpty || !_containsNote(current)) {
      return false;
    }

    final sameNote = _sameNote(current, next);
    if (!sameNote && _containsNote(next)) return false;

    _noteOptions = _sortNotes([
      for (final note in _noteOptions)
        if (_sameNote(note, current)) next else note,
    ]);

    _products = _products
        .map(
          (product) => product.copyWith(
            topNotes: _replaceNote(product.topNotes, current, next),
            middleNotes: _replaceNote(product.middleNotes, current, next),
            baseNotes: _replaceNote(product.baseNotes, current, next),
          ),
        )
        .toList(growable: false);

    notifyListeners();
    return true;
  }

  bool deleteNote(String note) {
    final cleaned = _cleanNote(note);
    if (cleaned.isEmpty || !_containsNote(cleaned)) return false;

    _noteOptions = [
      for (final note in _noteOptions)
        if (!_sameNote(note, cleaned)) note,
    ];
    _products = _products
        .map(
          (product) => product.copyWith(
            topNotes: _removeNote(product.topNotes, cleaned),
            middleNotes: _removeNote(product.middleNotes, cleaned),
            baseNotes: _removeNote(product.baseNotes, cleaned),
          ),
        )
        .toList(growable: false);

    notifyListeners();
    return true;
  }

  int noteUsageCount(String note) {
    final cleaned = _cleanNote(note);
    if (cleaned.isEmpty) return 0;

    return _products
        .where(
          (product) => product.notes.any((item) => _sameNote(item, cleaned)),
        )
        .length;
  }

  void reset() {
    _products = List<PerfumeProduct>.of(defaultProducts);
    _noteOptions = defaultEditableNoteOptions();
    notifyListeners();
  }

  bool _containsNote(String note) {
    return _noteOptions.any((existing) => _sameNote(existing, note));
  }

  static String _cleanNote(String note) {
    return note.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool _sameNote(String a, String b) {
    return _cleanNote(a).toLowerCase() == _cleanNote(b).toLowerCase();
  }

  static List<String> _sortNotes(List<String> notes) {
    final unique = <String>[];
    for (final note in notes.map(_cleanNote)) {
      if (note.isEmpty || unique.any((item) => _sameNote(item, note))) {
        continue;
      }
      unique.add(note);
    }
    return unique..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  static List<String> _replaceNote(
    List<String> notes,
    String current,
    String next,
  ) {
    return _dedupeNotes([
      for (final note in notes)
        if (_sameNote(note, current)) next else note,
    ]);
  }

  static List<String> _removeNote(List<String> notes, String noteToRemove) {
    return [
      for (final note in notes)
        if (!_sameNote(note, noteToRemove)) note,
    ];
  }

  static List<String> _dedupeNotes(List<String> notes) {
    final unique = <String>[];
    for (final note in notes.map(_cleanNote)) {
      if (note.isEmpty || unique.any((item) => _sameNote(item, note))) {
        continue;
      }
      unique.add(note);
    }
    return unique;
  }
}
