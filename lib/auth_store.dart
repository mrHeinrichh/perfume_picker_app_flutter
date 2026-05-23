import 'package:flutter_bloc/flutter_bloc.dart';
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

class AuthState {
  const AuthState({required this.currentAccount, required this.isReady});

  const AuthState.initial() : currentAccount = null, isReady = false;

  final AuthAccount? currentAccount;
  final bool isReady;

  bool get isLoggedIn => currentAccount != null;
  bool get isAdmin => currentAccount?.role == UserRole.admin;

  AuthState copyWith({
    AuthAccount? currentAccount,
    bool? clearCurrentAccount,
    bool? isReady,
  }) {
    return AuthState(
      currentAccount: clearCurrentAccount == true
          ? null
          : currentAccount ?? this.currentAccount,
      isReady: isReady ?? this.isReady,
    );
  }
}

class AuthStore extends Cubit<AuthState> {
  AuthStore({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication(),
      super(const AuthState.initial());

  static const adminUsername = 'admin';
  static const adminPassword = 'Admin@1234';

  final LocalAuthentication _localAuthentication;

  bool get isReady => state.isReady;
  AuthAccount? get currentAccount => state.currentAccount;
  bool get isLoggedIn => state.isLoggedIn;
  bool get isAdmin => state.isAdmin;

  Future<void> load() async {
    emit(state.copyWith(isReady: true));
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
    emit(
      state.copyWith(
        currentAccount: const AuthAccount(
          username: adminUsername,
          role: UserRole.admin,
        ),
      ),
    );
  }

  void logout() {
    emit(state.copyWith(clearCurrentAccount: true));
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
