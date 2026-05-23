part of '../../../../main.dart';

Future<bool> showAdminLogin(BuildContext context) async {
  if (AuthScope.read(context).isAdmin) return true;

  final unlocked = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AdminLoginSheet(),
  );

  return unlocked == true;
}
