import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotseeker_app/services/auth_service.dart';

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth State Provider
class AuthState {
  final bool isAuthenticated;
  final String? userType;
  final String? userEmail;
  final String? userId;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.userType,
    this.userEmail,
    this.userId,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userType,
    String? userEmail,
    String? userId,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userType: userType ?? this.userType,
      userEmail: userEmail ?? this.userEmail,
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState());

  /// Login
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.login(email, password);
      
      state = state.copyWith(
        isAuthenticated: true,
        userType: response.userType,
        userEmail: response.email,
        userId: response.userId.toString(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Partner Registration Step 1
  Future<void> partnerRegisterStep1(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.partnerRegistrationStep1(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Partner Registration Step 2
  Future<void> partnerRegisterStep2(String email, String mobile) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.partnerRegistrationStep2(
        email: email,
        mobile: mobile,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Partner Registration Step 3
  Future<void> partnerRegisterStep3(
    String email,
    String mobile,
    String otp,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.partnerRegistrationStep3(
        email: email,
        mobile: mobile,
        otp: otp,
      );
      
      state = state.copyWith(
        isAuthenticated: true,
        userType: 'PARTNER',
        userEmail: email,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }
}

/// Auth State Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
