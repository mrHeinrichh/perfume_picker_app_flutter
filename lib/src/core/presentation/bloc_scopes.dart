part of '../../../main.dart';

class AuthScope extends StatelessWidget {
  const AuthScope({super.key, required this.notifier, required this.child});

  final AuthStore notifier;
  final Widget child;

  static AuthStore watch(BuildContext context) {
    return context.watch<AuthStore>();
  }

  static AuthStore read(BuildContext context) {
    return context.read<AuthStore>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthStore>.value(value: notifier, child: child);
  }
}

class PerfumeScope extends StatelessWidget {
  const PerfumeScope({super.key, required this.notifier, required this.child});

  final PerfumeStore notifier;
  final Widget child;

  static PerfumeStore watch(BuildContext context) {
    return context.watch<PerfumeStore>();
  }

  static PerfumeStore read(BuildContext context) {
    return context.read<PerfumeStore>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PerfumeStore>.value(value: notifier, child: child);
  }
}
