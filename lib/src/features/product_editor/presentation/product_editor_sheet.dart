part of '../../../../main.dart';

class ProductEditorSheet extends StatefulWidget {
  const ProductEditorSheet({super.key, this.product});

  final PerfumeProduct? product;

  @override
  State<ProductEditorSheet> createState() => _ProductEditorSheetState();
}

class _ProductEditorSheetState extends State<ProductEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final Set<String> _fragranceCharacteristics;
  late final Set<String> _topNotes;
  late final Set<String> _middleNotes;
  late final Set<String> _baseNotes;
  late String _selectedGender;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _imageBytes = product?.imageBytes;
    _selectedGender = product?.gender ?? genderOptions.first;
    _fragranceCharacteristics = {...?product?.fragranceCharacteristics};
    _topNotes = {...?product?.topNotes};
    _middleNotes = {...?product?.middleNotes};
    _baseNotes = {...?product?.baseNotes};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_fragranceCharacteristics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose at least one fragrance characteristic.'),
        ),
      );
      return;
    }
    if (_topNotes.isEmpty || _middleNotes.isEmpty || _baseNotes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose at least one note for top, mid, and base.'),
        ),
      );
      return;
    }

    final existing = widget.product;
    final name = _nameController.text.trim();
    final id = existing?.id ?? _createId(name);
    final accent = existing?.accent ?? stableAccentFor(name);
    final glow = existing?.glow ?? stableGlowFor(accent);

    Navigator.of(context).pop(
      PerfumeProduct(
        id: id,
        name: name,
        description: _descriptionController.text.trim(),
        imageUrl: existing?.imageUrl ?? '',
        imageBytes: _imageBytes,
        gender: _selectedGender,
        fragranceCharacteristics: _fragranceCharacteristics.toList()..sort(),
        topNotes: _topNotes.toList(growable: false),
        middleNotes: _middleNotes.toList(growable: false),
        baseNotes: _baseNotes.toList(growable: false),
        accent: accent,
        glow: glow,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1400,
        maxHeight: 1400,
        imageQuality: 88,
      );

      if (pickedImage == null) return;

      final bytes = await pickedImage.readAsBytes();
      if (!mounted) return;

      setState(() => _imageBytes = bytes);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open gallery. Please try again.'),
        ),
      );
    }
  }

  void _removePickedImage() {
    setState(() => _imageBytes = null);
  }

  String _createId(String name) {
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return '$slug-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = PerfumeScope.watch(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final editing = widget.product != null;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: .92,
        minChildSize: .65,
        maxChildSize: .96,
        expand: false,
        builder: (context, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFCF6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          editing ? 'Edit product' : 'Add product',
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _EditorTextField(
                    controller: _nameController,
                    label: 'Name',
                    icon: Icons.local_florist_outlined,
                    requiredField: true,
                  ),
                  const SizedBox(height: 12),
                  _EditorTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    icon: Icons.notes_outlined,
                    requiredField: true,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _ImagePickerPanel(
                    product: widget.product,
                    imageBytes: _imageBytes,
                    onPickImage: _pickImage,
                    onRemoveImage: _imageBytes == null
                        ? null
                        : _removePickedImage,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Male / Female / Unisex',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<String>(
                    segments: genderOptions
                        .map(
                          (gender) => ButtonSegment<String>(
                            value: gender,
                            label: Text(gender),
                          ),
                        )
                        .toList(growable: false),
                    selected: {_selectedGender},
                    onSelectionChanged: (selection) {
                      setState(() => _selectedGender = selection.first);
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Fragrance characteristics',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: store.fragranceCharacteristicOptions.map((tag) {
                      final selected = _fragranceCharacteristics.contains(tag);
                      final foregroundColor = selected
                          ? Colors.white
                          : const Color(0xFF17201D);
                      final backgroundColor = selected
                          ? theme.colorScheme.primary
                          : Colors.white;

                      return FilterChip(
                        selected: selected,
                        showCheckmark: false,
                        avatar: selected
                            ? Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: foregroundColor,
                              )
                            : null,
                        label: Text(tag),
                        labelStyle: TextStyle(
                          color: foregroundColor,
                          fontWeight: FontWeight.w900,
                        ),
                        selectedColor: backgroundColor,
                        backgroundColor: backgroundColor,
                        side: BorderSide(
                          color: selected
                              ? theme.colorScheme.primary
                              : const Color(0xFFD8D0C4),
                        ),
                        onSelected: (_) {
                          setState(() {
                            if (selected) {
                              _fragranceCharacteristics.remove(tag);
                            } else {
                              _fragranceCharacteristics.add(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  _NoteSelectField(
                    title: 'Top notes',
                    icon: Icons.blur_on_rounded,
                    selectedNotes: _topNotes,
                    options: store.noteOptions,
                    onChanged: (notes) {
                      setState(() {
                        _topNotes
                          ..clear()
                          ..addAll(notes);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _NoteSelectField(
                    title: 'Mid notes',
                    icon: Icons.local_florist_outlined,
                    selectedNotes: _middleNotes,
                    options: store.noteOptions,
                    onChanged: (notes) {
                      setState(() {
                        _middleNotes
                          ..clear()
                          ..addAll(notes);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _NoteSelectField(
                    title: 'Base notes',
                    icon: Icons.layers_outlined,
                    selectedNotes: _baseNotes,
                    options: store.noteOptions,
                    onChanged: (notes) {
                      setState(() {
                        _baseNotes
                          ..clear()
                          ..addAll(notes);
                      });
                    },
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: Icon(
                      editing ? Icons.save_outlined : Icons.add_rounded,
                    ),
                    label: Text(editing ? 'Save changes' : 'Create product'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
