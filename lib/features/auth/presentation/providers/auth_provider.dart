import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

/// State of the authentication: Uninitialized, Loading, Authenticated, Unauthenticated, Error
class AuthState {
  final bool isLoading;
  final bool isInitialized;
  final models.User? user;
  final String? error;
  const AuthState({
    this.isLoading = false,
    this.isInitialized = false,
    this.user,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    bool? isInitialized,
    models.User? user,
    String? Function()? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      user: user ?? this.user,
      error: error != null ? error() : this.error,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository)..checkAuthStatus();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(error: () => null);
    try {
      final user = await _repository.getCurrentUser();
      state = state.copyWith(isLoading: false, isInitialized: true, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: () => e.toString(),
      );
    }
  }

  /// Force the auth state to be marked as initialized (unauthenticated).
  /// Used as a safety valve when the network times out on the splash screen.
  void forceInitialized() {
    if (!state.isInitialized) {
      state = state.copyWith(isLoading: false, isInitialized: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      await _repository.login(email, password);
      await checkAuthStatus(); // Refresh user
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      await _repository.register(email, password, name);
      // Auto-login after register
      await _repository.login(email, password);
      await checkAuthStatus();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
      return false;
    }
  }

  Future<bool> updatePreferences(Map<String, dynamic> prefs) async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      await _repository.updatePreferences(prefs);
      await checkAuthStatus();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      await _repository.logout();
      state = const AuthState().copyWith(isInitialized: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }
}
