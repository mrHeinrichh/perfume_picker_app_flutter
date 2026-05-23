part of '../../../../main.dart';

Future<void> showNoteManager(BuildContext context) async {
  if (!AuthScope.read(context).isAdmin) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Admin access is required.')));
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const NoteManagerSheet(),
  );
}

Future<void> showCharacteristicManager(BuildContext context) async {
  if (!AuthScope.read(context).isAdmin) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Admin access is required.')));
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CharacteristicManagerSheet(),
  );
}
