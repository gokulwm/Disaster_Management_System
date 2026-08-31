import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disaster_link/data/datasources/supabase_datasource.dart';
import 'package:disaster_link/data/models/volunteer_profile.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseDatasource _datasource = SupabaseDatasource();

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignupRequested>(_onSignup);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onAuthCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = _datasource.getCurrentUser();
      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }

      final profile = await _datasource.getVolunteerProfile();
      if (profile == null) {
        emit(AuthUnauthenticated());
        return;
      }

      if (profile.isVerified) {
        emit(AuthAuthenticated(profile));
      } else {
        emit(AuthUnverified(profile));
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _datasource.signIn(event.email, event.password);

      final profile = await _datasource.getVolunteerProfile();
      if (profile == null) {
        emit(AuthError('Profile not found. Please sign up first.'));
        return;
      }

      if (profile.isVerified) {
        emit(AuthAuthenticated(profile));
      } else {
        emit(AuthUnverified(profile));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignup(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _datasource.signUp(event.email, event.password);

      // Create volunteer profile after auth signup
      final user = _datasource.getCurrentUser();
      if (user != null) {
        await _datasource.createVolunteerProfile(
          fullName: event.fullName,
          phone: event.phone,
        );
      }

      final profile = await _datasource.getVolunteerProfile();
      if (profile != null) {
        emit(AuthUnverified(profile));
      } else {
        emit(AuthError('Failed to create profile'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _datasource.signOut();
    } catch (_) {}
    emit(AuthUnauthenticated());
  }
}