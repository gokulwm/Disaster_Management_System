part of 'connectivity_bloc.dart';
enum ConnectivityStatus { online, poor, offline, btMode }
class ConnectivityState {
  final ConnectivityStatus status;
  ConnectivityState(this.status);
}
