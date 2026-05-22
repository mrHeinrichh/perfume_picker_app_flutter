import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

enum UserRole { user, admin }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
    UserRole.user => 'User',
    UserRole.admin => 'Admin',
  };
}

class AuthAccount {
  const AuthAccount({required this.username, required this.role});

  final String username;
  final UserRole role;
}

class AuthResult {
  const AuthResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class AuthStore extends ChangeNotifier {
  AuthStore({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  static const adminUsername = 'admin';
  static const adminPassword = 'Admin@1234';

  final LocalAuthentication _localAuthentication;
  AuthAccount? _currentAccount;
  bool _isReady = false;

  bool get isReady => _isReady;
  AuthAccount? get currentAccount => _currentAccount;
  bool get isLoggedIn => _currentAccount != null;
  bool get isAdmin => _currentAccount?.role == UserRole.admin;

  Future<void> load() async {
    _isReady = true;
    notifyListeners();
  }

  Future<AuthResult> login({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    if (role != UserRole.admin) {
      return const AuthResult(
        success: false,
        message: 'Normal users can browse without logging in.',
      );
    }

    final normalizedUsername = _normalizeUsername(username);
    if (normalizedUsername != adminUsername || password != adminPassword) {
      return const AuthResult(
        success: false,
        message: 'Incorrect admin username or password.',
      );
    }

    _unlockAdmin();
    return const AuthResult(success: true, message: 'Admin access unlocked.');
  }

  Future<AuthResult> loginWithBiometrics() async {
    final biometricResult = await _authenticateAdmin();
    if (!biometricResult.success) return biometricResult;
    _unlockAdmin();
    return const AuthResult(success: true, message: 'Admin access unlocked.');
  }

  void _unlockAdmin() {
    _currentAccount = const AuthAccount(
      username: adminUsername,
      role: UserRole.admin,
    );
    notifyListeners();
  }

  void logout() {
    _currentAccount = null;
    notifyListeners();
  }

  Future<AuthResult> _authenticateAdmin() async {
    try {
      final supported = await _localAuthentication.isDeviceSupported();
      final canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      final biometrics = await _localAuthentication.getAvailableBiometrics();
      if (!supported || !canCheckBiometrics || biometrics.isEmpty) {
        return const AuthResult(
          success: false,
          message: 'Set up Face ID or biometrics on this device first.',
        );
      }

      final authenticated = await _localAuthentication.authenticate(
        localizedReason: 'Confirm admin access to manage perfume products.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      return AuthResult(
        success: authenticated,
        message: authenticated
            ? 'Admin verified.'
            : 'Biometric verification was cancelled.',
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Biometric login is unavailable on this device.',
      );
    }
  }

  String _normalizeUsername(String username) => username.trim().toLowerCase();
}
