import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'auth_provider.dart';

class AuthFormState {
  const AuthFormState({
    this.isSignUp = false,
    this.loading = false,
    this.error,
  });

  final bool isSignUp;
  final bool loading;
  final String? error;

  AuthFormState copyWith({bool? isSignUp, bool? loading, String? error}) {
    return AuthFormState(
      isSignUp: isSignUp ?? this.isSignUp,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class AuthFormNotifier extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  void setIsSignUp(bool value) {
    state = state.copyWith(isSignUp: value, error: null);
  }

  Future<AuthDestination?> submit({
    required String email,
    required String password,
    required String? gender,
  }) async {
    state = state.copyWith(loading: true, error: null);

    final authService = ref.read(authServiceProvider);

    try {
      if (state.isSignUp) {
        if (gender == null) {
          state = state.copyWith(
            loading: false,
            error: 'Please select your gender',
          );
          return null;
        }

        final hasSession = await authService.signUp(
          email: email,
          password: password,
          gender: gender,
        );

        if (!hasSession) {
          state = state.copyWith(
            loading: false,
            error: 'Please check your email for a confirmation link',
          );
          return null;
        }
      } else {
        await authService.signIn(email: email, password: password);

        final userId = authService.currentUser!.id;
        final destination = await authService.destinationAfterAuth(userId);

        state = state.copyWith(loading: false);

        return destination;
      }
    } on AuthException catch (e) {
      state = state.copyWith(loading: false, error: e.message);

      return null;
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: 'An unexpected error occurred',
      );

      return null;
    }
  }
}

final authFormProvider = NotifierProvider<AuthFormNotifier, AuthFormState>(
  AuthFormNotifier.new,
);
