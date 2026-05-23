import 'package:flutter/foundation.dart';

import 'catalog.dart';
import 'models.dart';

class PerfumeStore extends ChangeNotifier {
  PerfumeStore()
    : _products = List<PerfumeProduct>.of(defaultProducts),
      _noteOptions = defaultEditableNoteOptions(),
      _fragranceCharacteristicOptions =
          defaultEditableFragranceCharacteristicOptions();

  List<PerfumeProduct> _products;
  List<String> _noteOptions;
  List<String> _fragranceCharacteristicOptions;
  bool _dummyDataEnabled = true;

  List<PerfumeProduct> get products => List.unmodifiable(_products);

  List<String> get noteOptions => List.unmodifiable(_noteOptions);

  List<String> get fragranceCharacteristicOptions =>
      List.unmodifiable(_fragranceCharacteristicOptions);

  bool get dummyDataEnabled => _dummyDataEnabled;

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
    if (!_isValidNote(cleaned) || _containsNote(cleaned)) return false;

    _noteOptions = _sortNotes([..._noteOptions, cleaned]);
    notifyListeners();
    return true;
  }

  bool renameNote(String currentNote, String nextNote) {
    final current = _cleanNote(currentNote);
    final next = _cleanNote(nextNote);
    if (!_isValidNote(next) || current.isEmpty || !_containsNote(current)) {
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

  bool addCharacteristic(String characteristic) {
    final cleaned = _cleanCharacteristic(characteristic);
    if (!_isValidCharacteristic(cleaned) || _containsCharacteristic(cleaned)) {
      return false;
    }

    _fragranceCharacteristicOptions = _sortCharacteristics([
      ..._fragranceCharacteristicOptions,
      cleaned,
    ]);
    notifyListeners();
    return true;
  }

  bool renameCharacteristic(String currentCharacteristic, String nextValue) {
    final current = _cleanCharacteristic(currentCharacteristic);
    final next = _cleanCharacteristic(nextValue);
    if (!_isValidCharacteristic(next) ||
        current.isEmpty ||
        !_containsCharacteristic(current)) {
      return false;
    }

    final sameCharacteristic = _sameCharacteristic(current, next);
    if (!sameCharacteristic && _containsCharacteristic(next)) return false;

    _fragranceCharacteristicOptions = _sortCharacteristics([
      for (final characteristic in _fragranceCharacteristicOptions)
        if (_sameCharacteristic(characteristic, current))
          next
        else
          characteristic,
    ]);

    _products = _products
        .map(
          (product) => product.copyWith(
            fragranceCharacteristics: _replaceCharacteristic(
              product.fragranceCharacteristics,
              current,
              next,
            ),
          ),
        )
        .toList(growable: false);

    notifyListeners();
    return true;
  }

  bool deleteCharacteristic(String characteristic) {
    final cleaned = _cleanCharacteristic(characteristic);
    if (cleaned.isEmpty || !_containsCharacteristic(cleaned)) return false;

    _fragranceCharacteristicOptions = [
      for (final characteristic in _fragranceCharacteristicOptions)
        if (!_sameCharacteristic(characteristic, cleaned)) characteristic,
    ];
    _products = _products
        .map(
          (product) => product.copyWith(
            fragranceCharacteristics: _removeCharacteristic(
              product.fragranceCharacteristics,
              cleaned,
            ),
          ),
        )
        .toList(growable: false);

    notifyListeners();
    return true;
  }

  int characteristicUsageCount(String characteristic) {
    final cleaned = _cleanCharacteristic(characteristic);
    if (cleaned.isEmpty) return 0;

    return _products
        .where(
          (product) => product.fragranceCharacteristics.any(
            (item) => _sameCharacteristic(item, cleaned),
          ),
        )
        .length;
  }

  void reset() {
    _dummyDataEnabled = true;
    _products = List<PerfumeProduct>.of(defaultProducts);
    _noteOptions = defaultEditableNoteOptions();
    _fragranceCharacteristicOptions =
        defaultEditableFragranceCharacteristicOptions();
    notifyListeners();
  }

  void setDummyDataEnabled(bool enabled) {
    if (_dummyDataEnabled == enabled) return;

    _dummyDataEnabled = enabled;
    if (enabled) {
      _products = List<PerfumeProduct>.of(defaultProducts);
      _noteOptions = defaultEditableNoteOptions();
      _fragranceCharacteristicOptions = _sortCharacteristics([
        ..._fragranceCharacteristicOptions,
        ...defaultEditableFragranceCharacteristicOptions(),
      ]);
    } else {
      _products = [];
      _noteOptions = [];
    }
    notifyListeners();
  }

  bool _containsCharacteristic(String characteristic) {
    return _fragranceCharacteristicOptions.any(
      (existing) => _sameCharacteristic(existing, characteristic),
    );
  }

  bool _containsNote(String note) {
    return _noteOptions.any((existing) => _sameNote(existing, note));
  }

  static String _cleanNote(String note) {
    return note.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool _isValidNote(String note) {
    return note.isNotEmpty && note.length <= noteNameMaxLength;
  }

  static String _cleanCharacteristic(String characteristic) {
    return characteristic.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool _isValidCharacteristic(String characteristic) {
    return characteristic.isNotEmpty &&
        characteristic.length <= fragranceCharacteristicNameMaxLength;
  }

  static bool _sameNote(String a, String b) {
    return _cleanNote(a).toLowerCase() == _cleanNote(b).toLowerCase();
  }

  static bool _sameCharacteristic(String a, String b) {
    return _cleanCharacteristic(a).toLowerCase() ==
        _cleanCharacteristic(b).toLowerCase();
  }

  static List<String> _sortNotes(List<String> notes) {
    final unique = <String>[];
    for (final note in notes.map(_cleanNote)) {
      if (!_isValidNote(note) || unique.any((item) => _sameNote(item, note))) {
        continue;
      }
      unique.add(note);
    }
    return unique..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  static List<String> _sortCharacteristics(List<String> characteristics) {
    final unique = <String>[];
    for (final characteristic in characteristics.map(_cleanCharacteristic)) {
      if (!_isValidCharacteristic(characteristic) ||
          unique.any((item) => _sameCharacteristic(item, characteristic))) {
        continue;
      }
      unique.add(characteristic);
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
      if (!_isValidNote(note) || unique.any((item) => _sameNote(item, note))) {
        continue;
      }
      unique.add(note);
    }
    return unique;
  }

  static List<String> _replaceCharacteristic(
    List<String> characteristics,
    String current,
    String next,
  ) {
    return _dedupeCharacteristics([
      for (final characteristic in characteristics)
        if (_sameCharacteristic(characteristic, current))
          next
        else
          characteristic,
    ]);
  }

  static List<String> _removeCharacteristic(
    List<String> characteristics,
    String characteristicToRemove,
  ) {
    return [
      for (final characteristic in characteristics)
        if (!_sameCharacteristic(characteristic, characteristicToRemove))
          characteristic,
    ];
  }

  static List<String> _dedupeCharacteristics(List<String> characteristics) {
    final unique = <String>[];
    for (final characteristic in characteristics.map(_cleanCharacteristic)) {
      if (!_isValidCharacteristic(characteristic) ||
          unique.any((item) => _sameCharacteristic(item, characteristic))) {
        continue;
      }
      unique.add(characteristic);
    }
    return unique;
  }
}
