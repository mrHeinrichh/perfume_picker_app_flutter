import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'catalog.dart';
import 'models.dart';
import 'src/core/data/catalog_persistence.dart';

class PerfumeCatalogState {
  const PerfumeCatalogState({
    required this.products,
    required this.noteOptions,
    required this.fragranceCharacteristicOptions,
    required this.dummyDataEnabled,
  });

  PerfumeCatalogState.initial()
    : products = List<PerfumeProduct>.of(defaultProducts),
      noteOptions = defaultEditableNoteOptions(),
      fragranceCharacteristicOptions =
          defaultEditableFragranceCharacteristicOptions(),
      dummyDataEnabled = true;

  PerfumeCatalogState.fromSnapshot(CatalogSnapshot snapshot)
    : products = List<PerfumeProduct>.of(snapshot.products),
      noteOptions = List<String>.of(snapshot.noteOptions),
      fragranceCharacteristicOptions = List<String>.of(
        snapshot.fragranceCharacteristicOptions,
      ),
      dummyDataEnabled = snapshot.dummyDataEnabled;

  final List<PerfumeProduct> products;
  final List<String> noteOptions;
  final List<String> fragranceCharacteristicOptions;
  final bool dummyDataEnabled;

  CatalogSnapshot toSnapshot() {
    return CatalogSnapshot(
      products: products,
      noteOptions: noteOptions,
      fragranceCharacteristicOptions: fragranceCharacteristicOptions,
      dummyDataEnabled: dummyDataEnabled,
    );
  }

  PerfumeCatalogState copyWith({
    List<PerfumeProduct>? products,
    List<String>? noteOptions,
    List<String>? fragranceCharacteristicOptions,
    bool? dummyDataEnabled,
  }) {
    return PerfumeCatalogState(
      products: products ?? this.products,
      noteOptions: noteOptions ?? this.noteOptions,
      fragranceCharacteristicOptions:
          fragranceCharacteristicOptions ?? this.fragranceCharacteristicOptions,
      dummyDataEnabled: dummyDataEnabled ?? this.dummyDataEnabled,
    );
  }
}

class PerfumeStore extends Cubit<PerfumeCatalogState> {
  PerfumeStore({CatalogPersistence? persistence})
    : _persistence = persistence,
      super(PerfumeCatalogState.initial());

  final CatalogPersistence? _persistence;

  List<PerfumeProduct> get products => List.unmodifiable(state.products);

  List<String> get noteOptions => List.unmodifiable(state.noteOptions);

  List<String> get fragranceCharacteristicOptions =>
      List.unmodifiable(state.fragranceCharacteristicOptions);

  bool get dummyDataEnabled => state.dummyDataEnabled;

  Future<void> load() async {
    final snapshot = await _persistence?.load();
    if (snapshot == null || isClosed) return;
    emit(PerfumeCatalogState.fromSnapshot(snapshot));
  }

  PerfumeProduct? byId(String id) {
    for (final product in state.products) {
      if (product.id == id) return product;
    }
    return null;
  }

  void add(PerfumeProduct product) {
    _setState(state.copyWith(products: [product, ...state.products]));
  }

  void update(PerfumeProduct product) {
    _setState(
      state.copyWith(
        products: [
          for (final existing in state.products)
            if (existing.id == product.id) product else existing,
        ],
      ),
    );
  }

  void delete(String id) {
    _setState(
      state.copyWith(
        products: state.products
            .where((product) => product.id != id)
            .toList(growable: false),
      ),
    );
  }

  bool addNote(String note) {
    final cleaned = _cleanNote(note);
    if (!_isValidNote(cleaned) || _containsNote(cleaned)) return false;

    _setState(
      state.copyWith(noteOptions: _sortNotes([...state.noteOptions, cleaned])),
    );
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

    _setState(
      state.copyWith(
        noteOptions: _sortNotes([
          for (final note in state.noteOptions)
            if (_sameNote(note, current)) next else note,
        ]),
        products: state.products
            .map(
              (product) => product.copyWith(
                topNotes: _replaceNote(product.topNotes, current, next),
                middleNotes: _replaceNote(product.middleNotes, current, next),
                baseNotes: _replaceNote(product.baseNotes, current, next),
              ),
            )
            .toList(growable: false),
      ),
    );
    return true;
  }

  bool deleteNote(String note) {
    final cleaned = _cleanNote(note);
    if (cleaned.isEmpty || !_containsNote(cleaned)) return false;

    _setState(
      state.copyWith(
        noteOptions: [
          for (final note in state.noteOptions)
            if (!_sameNote(note, cleaned)) note,
        ],
        products: state.products
            .map(
              (product) => product.copyWith(
                topNotes: _removeNote(product.topNotes, cleaned),
                middleNotes: _removeNote(product.middleNotes, cleaned),
                baseNotes: _removeNote(product.baseNotes, cleaned),
              ),
            )
            .toList(growable: false),
      ),
    );
    return true;
  }

  int noteUsageCount(String note) {
    final cleaned = _cleanNote(note);
    if (cleaned.isEmpty) return 0;

    return state.products
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

    _setState(
      state.copyWith(
        fragranceCharacteristicOptions: _sortCharacteristics([
          ...state.fragranceCharacteristicOptions,
          cleaned,
        ]),
      ),
    );
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

    _setState(
      state.copyWith(
        fragranceCharacteristicOptions: _sortCharacteristics([
          for (final characteristic in state.fragranceCharacteristicOptions)
            if (_sameCharacteristic(characteristic, current))
              next
            else
              characteristic,
        ]),
        products: state.products
            .map(
              (product) => product.copyWith(
                fragranceCharacteristics: _replaceCharacteristic(
                  product.fragranceCharacteristics,
                  current,
                  next,
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
    return true;
  }

  bool deleteCharacteristic(String characteristic) {
    final cleaned = _cleanCharacteristic(characteristic);
    if (cleaned.isEmpty || !_containsCharacteristic(cleaned)) return false;

    _setState(
      state.copyWith(
        fragranceCharacteristicOptions: [
          for (final characteristic in state.fragranceCharacteristicOptions)
            if (!_sameCharacteristic(characteristic, cleaned)) characteristic,
        ],
        products: state.products
            .map(
              (product) => product.copyWith(
                fragranceCharacteristics: _removeCharacteristic(
                  product.fragranceCharacteristics,
                  cleaned,
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
    return true;
  }

  int characteristicUsageCount(String characteristic) {
    final cleaned = _cleanCharacteristic(characteristic);
    if (cleaned.isEmpty) return 0;

    return state.products
        .where(
          (product) => product.fragranceCharacteristics.any(
            (item) => _sameCharacteristic(item, cleaned),
          ),
        )
        .length;
  }

  void reset() {
    _setState(PerfumeCatalogState.initial());
  }

  void setDummyDataEnabled(bool enabled) {
    if (state.dummyDataEnabled == enabled) return;

    _setState(
      state.copyWith(
        dummyDataEnabled: enabled,
        products: enabled ? List<PerfumeProduct>.of(defaultProducts) : [],
        noteOptions: enabled ? defaultEditableNoteOptions() : [],
        fragranceCharacteristicOptions: enabled
            ? defaultEditableFragranceCharacteristicOptions()
            : [],
      ),
    );
  }

  void _setState(PerfumeCatalogState nextState) {
    emit(nextState);
    final persistence = _persistence;
    if (persistence == null) return;
    unawaited(persistence.save(nextState.toSnapshot()));
  }

  bool _containsCharacteristic(String characteristic) {
    return state.fragranceCharacteristicOptions.any(
      (existing) => _sameCharacteristic(existing, characteristic),
    );
  }

  bool _containsNote(String note) {
    return state.noteOptions.any((existing) => _sameNote(existing, note));
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
