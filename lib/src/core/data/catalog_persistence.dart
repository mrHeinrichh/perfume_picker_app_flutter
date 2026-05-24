import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models.dart';

class CatalogSnapshot {
  const CatalogSnapshot({
    required this.products,
    required this.noteOptions,
    required this.fragranceCharacteristicOptions,
    required this.dummyDataEnabled,
  });

  final List<PerfumeProduct> products;
  final List<String> noteOptions;
  final List<String> fragranceCharacteristicOptions;
  final bool dummyDataEnabled;
}

abstract class CatalogPersistence {
  Future<CatalogSnapshot?> load();

  Future<void> save(CatalogSnapshot snapshot);
}

class SharedPreferencesCatalogPersistence implements CatalogPersistence {
  const SharedPreferencesCatalogPersistence();

  static const _snapshotKey = 'perfume_picker.catalog_snapshot.v1';

  @override
  Future<CatalogSnapshot?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawSnapshot = preferences.getString(_snapshotKey);
    if (rawSnapshot == null) return null;

    try {
      final json = jsonDecode(rawSnapshot);
      if (json is! Map<String, Object?>) return null;
      return _snapshotFromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(CatalogSnapshot snapshot) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _snapshotKey,
      jsonEncode(_snapshotToJson(snapshot)),
    );
  }

  static Map<String, Object?> _snapshotToJson(CatalogSnapshot snapshot) {
    return {
      'products': snapshot.products.map(_productToJson).toList(),
      'noteOptions': snapshot.noteOptions,
      'fragranceCharacteristicOptions': snapshot.fragranceCharacteristicOptions,
      'dummyDataEnabled': snapshot.dummyDataEnabled,
    };
  }

  static CatalogSnapshot _snapshotFromJson(Map<String, Object?> json) {
    return CatalogSnapshot(
      products: _jsonList(json['products']).map(_productFromJson).toList(),
      noteOptions: _stringList(json['noteOptions']),
      fragranceCharacteristicOptions: _stringList(
        json['fragranceCharacteristicOptions'],
      ),
      dummyDataEnabled: json['dummyDataEnabled'] == true,
    );
  }

  static Map<String, Object?> _productToJson(PerfumeProduct product) {
    return {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'imageBytes': product.imageBytes == null
          ? null
          : base64Encode(product.imageBytes!),
      'gender': product.gender,
      'fragranceCharacteristics': product.fragranceCharacteristics,
      'topNotes': product.topNotes,
      'middleNotes': product.middleNotes,
      'baseNotes': product.baseNotes,
      'accent': product.accent.toARGB32(),
      'glow': product.glow.toARGB32(),
    };
  }

  static PerfumeProduct _productFromJson(Map<String, Object?> json) {
    final name = _string(json['name'], fallback: 'Untitled perfume');
    final accent = _color(json['accent'], fallback: stableAccentFor(name));

    return PerfumeProduct(
      id: _string(json['id'], fallback: 'product-${name.hashCode}'),
      name: name,
      description: _string(json['description']),
      imageUrl: _string(json['imageUrl']),
      imageBytes: _bytes(json['imageBytes']),
      gender: _string(json['gender'], fallback: 'Unisex'),
      fragranceCharacteristics: _stringList(json['fragranceCharacteristics']),
      topNotes: _stringList(json['topNotes']),
      middleNotes: _stringList(json['middleNotes']),
      baseNotes: _stringList(json['baseNotes']),
      accent: accent,
      glow: _color(json['glow'], fallback: stableGlowFor(accent)),
    );
  }

  static List<Map<String, Object?>> _jsonList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (item) => item.map(
            (key, value) => MapEntry(key.toString(), value as Object?),
          ),
        )
        .toList(growable: false);
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static String _string(Object? value, {String fallback = ''}) {
    if (value is! String) return fallback;
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  static Uint8List? _bytes(Object? value) {
    if (value is! String || value.isEmpty) return null;
    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }

  static Color _color(Object? value, {required Color fallback}) {
    if (value is num) return Color(value.toInt());
    return fallback;
  }
}
