part of '../../../../main.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.watch(context);

    if (!auth.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const LandingPage();
  }
}
