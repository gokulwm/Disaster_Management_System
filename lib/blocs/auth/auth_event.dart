part of 'auth_bloc.dart';
abstract class AuthEvent {}
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested(this.email, this.password);
}
class AuthSignupRequested extends AuthEvent {
  final String email, password, fullName, phone;
  AuthSignupRequested(this.email, this.password, this.fullName, this.phone);
}
class AuthLogoutRequested extends AuthEvent {}
class AuthCheckRequested extends AuthEvent {}
