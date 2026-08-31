part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final VolunteerProfile volunteerProfile;
  AuthAuthenticated(this.volunteerProfile);
}

class AuthUnverified extends AuthState {
  final VolunteerProfile volunteerProfile;
  AuthUnverified(this.volunteerProfile);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}