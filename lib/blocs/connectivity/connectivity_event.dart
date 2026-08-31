part of 'connectivity_bloc.dart';
abstract class ConnectivityEvent {}
class ConnectivityChanged extends ConnectivityEvent {
  final ConnectivityStatus status;
  ConnectivityChanged(this.status);
}
class ConnectivityCheckRequested extends ConnectivityEvent {}
