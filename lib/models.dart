import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

class FilterGroup {
  const FilterGroup({
    required this.title,
    required this.icon,
    required this.options,
  });

  final String title;
  final IconData icon;
  final List<String> options;
}

class PerfumeProduct {
  const PerfumeProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.imageBytes,
    required this.gender,
    required this.fragranceCharacteristics,
    required this.topNotes,
    required this.middleNotes,
    required this.baseNotes,
    required this.accent,
    required this.glow,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final Uint8List? imageBytes;
  final String gender;
  final List<String> fragranceCharacteristics;
  final List<String> topNotes;
  final List<String> middleNotes;
  final List<String> baseNotes;
  final Color accent;
  final Color glow;

  List<String> get notes => [...topNotes, ...middleNotes, ...baseNotes];

  List<String> get filterTerms => [
    gender,
    ...fragranceCharacteristics,
    ...notes,
  ];

  PerfumeProduct copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    Uint8List? imageBytes,
    String? gender,
    List<String>? fragranceCharacteristics,
    List<String>? topNotes,
    List<String>? middleNotes,
    List<String>? baseNotes,
    Color? accent,
    Color? glow,
  }) {
    return PerfumeProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
      gender: gender ?? this.gender,
      fragranceCharacteristics:
          fragranceCharacteristics ?? this.fragranceCharacteristics,
      topNotes: topNotes ?? this.topNotes,
      middleNotes: middleNotes ?? this.middleNotes,
      baseNotes: baseNotes ?? this.baseNotes,
      accent: accent ?? this.accent,
      glow: glow ?? this.glow,
    );
  }
}

class PerfumeMatch {
  const PerfumeMatch({
    required this.perfume,
    required this.matchedTags,
    required this.totalFilters,
  });

  final PerfumeProduct perfume;
  final List<String> matchedTags;
  final int totalFilters;

  int get score => matchedTags.length;

  int get matchPercentage {
    if (totalFilters == 0) {
      return 0;
    }

    return ((score / totalFilters) * 100).round().clamp(0, 100);
  }
}

List<PerfumeMatch> rankPerfumes(
  Set<String> selectedFilters,
  List<PerfumeProduct> products,
) {
  final matches = products.map((perfume) {
    final matchedTags = perfume.filterTerms
        .where((tag) => selectedFilters.contains(tag))
        .toList(growable: false);
    return PerfumeMatch(
      perfume: perfume,
      matchedTags: matchedTags,
      totalFilters: selectedFilters.length,
    );
  }).toList();

  matches.sort((a, b) {
    final matchSort = b.score.compareTo(a.score);
    if (matchSort != 0) return matchSort;

    final percentageSort = b.matchPercentage.compareTo(a.matchPercentage);
    if (percentageSort != 0) return percentageSort;

    return a.perfume.name.compareTo(b.perfume.name);
  });

  return matches;
}

List<String> splitCommaList(String value) {
  return value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

String joinCommaList(List<String> value) => value.join(', ');

Color stableAccentFor(String seed) {
  const accents = [
    Color(0xFF2F6F64),
    Color(0xFFE46D55),
    Color(0xFF6C5A8A),
    Color(0xFF2F88A7),
    Color(0xFFB26442),
    Color(0xFFC54D5F),
  ];
  final index = seed.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
  return accents[index % accents.length];
}

Color stableGlowFor(Color accent) {
  final hsl = HSLColor.fromColor(accent);
  return hsl
      .withLightness(math.min(.82, hsl.lightness + .32))
      .withSaturation(math.max(.38, hsl.saturation - .08))
      .toColor();
}
