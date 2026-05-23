part of '../../../../main.dart';

String _cleanNoteLabel(String note) {
  return note.trim().replaceAll(RegExp(r'\s+'), ' ');
}

bool _sameNoteLabel(String a, String b) {
  return _cleanNoteLabel(a).toLowerCase() == _cleanNoteLabel(b).toLowerCase();
}

String _cleanCharacteristicLabel(String characteristic) {
  return characteristic.trim().replaceAll(RegExp(r'\s+'), ' ');
}

List<String> _mergeNoteOptions(List<String> notes) {
  final unique = <String>[];
  for (final note in notes.map(_cleanNoteLabel)) {
    if (note.isEmpty || unique.any((item) => _sameNoteLabel(item, note))) {
      continue;
    }
    unique.add(note);
  }
  return unique..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

Future<void> showProductEditor(
  BuildContext context, {
  PerfumeProduct? product,
}) async {
  if (!AuthScope.read(context).isAdmin) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Admin access is required.')));
    return;
  }

  final store = PerfumeScope.read(context);
  final saved = await showModalBottomSheet<PerfumeProduct>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProductEditorSheet(product: product),
  );

  if (saved == null) return;

  if (product == null) {
    store.add(saved);
  } else {
    store.update(saved);
  }
}

Future<bool> confirmDeleteProduct(
  BuildContext context,
  PerfumeProduct product,
) async {
  if (!AuthScope.read(context).isAdmin) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Admin access is required.')));
    return false;
  }

  final store = PerfumeScope.read(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete product?'),
        content: Text('${product.name} will be removed from this demo list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return false;
  store.delete(product.id);
  return true;
}
