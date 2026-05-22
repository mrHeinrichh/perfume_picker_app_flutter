import 'package:flutter/material.dart';

import 'models.dart';

const genderOptions = ['Male', 'Female', 'Unisex'];

const fragranceCharacteristicOptions = [
  'Woody',
  'Fruity',
  'Floral',
  'Fresh',
  'Citrus',
  'Amber',
  'Aquatic',
  'Spicy',
  'Green',
  'Musky',
  'Leather',
  'Gourmand',
  'Powdery',
];

const noteFilterOptions = [
  'Bergamot',
  'Grapefruit',
  'Lemon',
  'Pink pepper',
  'Lavender',
  'Jasmine',
  'Rose',
  'Iris',
  'Saffron',
  'Vanilla',
  'Musk',
  'Cedar',
  'Sandalwood',
  'Patchouli',
  'Sea salt',
  'Sage',
  'Cardamom',
  'Violet',
  'Amberwood',
  'Ambrox',
  'Black orchid',
  'Wild strawberry',
];

const filterGroups = <FilterGroup>[
  FilterGroup(
    title: 'Male / Female / Unisex',
    icon: Icons.wc_outlined,
    options: genderOptions,
  ),
  FilterGroup(
    title: 'Fragrance characteristics',
    icon: Icons.auto_awesome_outlined,
    options: fragranceCharacteristicOptions,
  ),
  FilterGroup(
    title: 'Notes',
    icon: Icons.blur_on_rounded,
    options: noteFilterOptions,
  ),
];

List<String> get allFilterOptions => filterGroups
    .expand((group) => group.options)
    .toSet()
    .toList(growable: false);

const defaultProducts = <PerfumeProduct>[
  PerfumeProduct(
    id: 'bleu-de-chanel-edp',
    name: 'CHANEL Bleu de Chanel Eau de Parfum',
    description:
        'A polished aromatic woody scent with citrus lift, amber warmth, cedar, and clean musk.',
    imageUrl: 'assets/images/perfumes/bleu_de_chanel.png',
    gender: 'Male',
    fragranceCharacteristics: ['Woody', 'Citrus', 'Amber', 'Musky'],
    topNotes: ['Grapefruit', 'Lemon', 'Mint', 'Pink pepper'],
    middleNotes: ['Ginger', 'Nutmeg', 'Jasmine'],
    baseNotes: ['Incense', 'Sandalwood', 'Cedar', 'Musk'],
    accent: Color(0xFF24455C),
    glow: Color(0xFF88A7BC),
  ),
  PerfumeProduct(
    id: 'dior-sauvage-edp',
    name: 'Dior Sauvage Eau de Parfum',
    description:
        'Bright bergamot, spicy freshness, and smooth vanilla amber made for high-impact daily wear.',
    imageUrl: 'assets/images/perfumes/dior_sauvage.jpg',
    gender: 'Male',
    fragranceCharacteristics: ['Fresh', 'Spicy', 'Citrus', 'Amber'],
    topNotes: ['Calabrian bergamot', 'Pepper'],
    middleNotes: ['Lavender', 'Sichuan pepper', 'Star anise', 'Nutmeg'],
    baseNotes: ['Ambroxan', 'Vanilla'],
    accent: Color(0xFF2D5973),
    glow: Color(0xFF9FC6D6),
  ),
  PerfumeProduct(
    id: 'ysl-libre-edp',
    name: 'Yves Saint Laurent Libre Eau de Parfum',
    description:
        'Orange blossom and lavender over warm vanilla, built as a clean but confident floral amber.',
    imageUrl: 'assets/images/perfumes/ysl_libre.jpg',
    gender: 'Female',
    fragranceCharacteristics: ['Floral', 'Amber', 'Musky', 'Citrus'],
    topNotes: ['Lavender', 'Mandarin orange', 'Blackcurrant'],
    middleNotes: ['Orange blossom', 'Jasmine'],
    baseNotes: ['Vanilla', 'Musk accord', 'Cedar', 'Ambergris accord'],
    accent: Color(0xFFB66A39),
    glow: Color(0xFFE8BD8D),
  ),
  PerfumeProduct(
    id: 'baccarat-rouge-540-edp',
    name: 'Maison Francis Kurkdjian Baccarat Rouge 540',
    description:
        'A luminous woody amber floral with airy jasmine, saffron, ambergris-style facets, and cedar.',
    imageUrl: 'assets/images/perfumes/baccarat_rouge_540.jpg',
    gender: 'Unisex',
    fragranceCharacteristics: ['Amber', 'Woody', 'Floral'],
    topNotes: ['Saffron', 'Jasmine'],
    middleNotes: ['Amberwood', 'Ambergris accord'],
    baseNotes: ['Fir resin', 'Cedar', 'Ethyl maltol'],
    accent: Color(0xFFB13F3D),
    glow: Color(0xFFF0A6A2),
  ),
  PerfumeProduct(
    id: 'jo-malone-wood-sage-sea-salt',
    name: 'Jo Malone Wood Sage & Sea Salt Cologne',
    description:
        'A breezy mineral woody scent inspired by windswept coastlines, sea salt, and earthy sage.',
    imageUrl: 'assets/images/perfumes/wood_sage_sea_salt.jpg',
    gender: 'Unisex',
    fragranceCharacteristics: ['Fresh', 'Woody', 'Aquatic', 'Green'],
    topNotes: ['Ambrette seeds'],
    middleNotes: ['Sea salt'],
    baseNotes: ['Sage'],
    accent: Color(0xFF4D7F73),
    glow: Color(0xFFA5D3C2),
  ),
  PerfumeProduct(
    id: 'le-labo-santal-33',
    name: 'Le Labo Santal 33 Eau de Parfum',
    description:
        'A dry, smoky sandalwood profile with cardamom, violet, iris, leather, ambrox, and musk.',
    imageUrl: 'assets/images/perfumes/santal_33.jpg',
    gender: 'Unisex',
    fragranceCharacteristics: ['Woody', 'Spicy', 'Leather', 'Musky'],
    topNotes: ['Cardamom', 'Violet'],
    middleNotes: ['Iris', 'Papyrus'],
    baseNotes: ['Sandalwood', 'Cedarwood', 'Leather', 'Ambrox', 'Musk'],
    accent: Color(0xFF7A6245),
    glow: Color(0xFFD7C1A0),
  ),
  PerfumeProduct(
    id: 'tom-ford-black-orchid-edp',
    name: 'TOM FORD Black Orchid Eau de Parfum',
    description:
        'A dark floral amber with black truffle, ylang ylang, orchid, fruit, woods, and patchouli.',
    imageUrl: 'assets/images/perfumes/black_orchid.jpg',
    gender: 'Unisex',
    fragranceCharacteristics: ['Floral', 'Amber', 'Spicy', 'Woody'],
    topNotes: ['Black truffle', 'Ylang ylang', 'Bergamot', 'Blackcurrant'],
    middleNotes: ['Black orchid', 'Fruity notes', 'Lotus wood'],
    baseNotes: ['Patchouli', 'Vanilla', 'Sandalwood', 'Vetiver'],
    accent: Color(0xFF242025),
    glow: Color(0xFFB19691),
  ),
  PerfumeProduct(
    id: 'marc-jacobs-daisy-edt',
    name: 'Marc Jacobs Daisy Eau de Toilette',
    description:
        'A sunny, youthful floral with wild strawberry, violet petals, jasmine, and soft woods.',
    imageUrl: 'assets/images/perfumes/daisy.jpg',
    gender: 'Female',
    fragranceCharacteristics: ['Fresh', 'Floral', 'Green', 'Fruity'],
    topNotes: ['Wild strawberry', 'Violet leaves', 'Ruby red grapefruit'],
    middleNotes: ['Violet petals', 'Jasmine', 'Gardenia'],
    baseNotes: ['White woods', 'Musk', 'Vanilla'],
    accent: Color(0xFFE0B84F),
    glow: Color(0xFFF3E2A4),
  ),
  PerfumeProduct(
    id: 'viktor-rolf-flowerbomb-edp',
    name: 'Viktor&Rolf Flowerbomb Eau de Parfum',
    description:
        'A sweet floral explosion of freesia, rose, jasmine, patchouli, vanilla, and musk.',
    imageUrl: 'assets/images/perfumes/flowerbomb.jpg',
    gender: 'Female',
    fragranceCharacteristics: ['Floral', 'Gourmand', 'Amber', 'Powdery'],
    topNotes: ['Tea', 'Bergamot', 'Osmanthus'],
    middleNotes: ['Freesia', 'Rose', 'Jasmine', 'Orchid'],
    baseNotes: ['Patchouli', 'Vanilla', 'Musk'],
    accent: Color(0xFFC54D76),
    glow: Color(0xFFFFB2C8),
  ),
  PerfumeProduct(
    id: 'glossier-you-edp',
    name: 'Glossier You Eau de Parfum',
    description:
        'A soft skin scent built around pink pepper, iris, ambrette, and creamy ambrox.',
    imageUrl: 'assets/images/perfumes/glossier_you.jpg',
    gender: 'Unisex',
    fragranceCharacteristics: ['Musky', 'Fresh', 'Powdery'],
    topNotes: ['Pink pepper'],
    middleNotes: ['Iris'],
    baseNotes: ['Ambrette', 'Ambrox', 'Musk'],
    accent: Color(0xFFE16E7A),
    glow: Color(0xFFFFC4C8),
  ),
];
