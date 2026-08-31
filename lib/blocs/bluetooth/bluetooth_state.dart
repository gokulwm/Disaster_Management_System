part of 'bluetooth_bloc.dart';
abstract class BluetoothState {}
class BluetoothInitial extends BluetoothState {}
class BluetoothDiscovering extends BluetoothState {
  final List<dynamic> devicesFound;
  BluetoothDiscovering(this.devicesFound);
}
class BluetoothRelaying extends BluetoothState {}
class BluetoothSyncing extends BluetoothState {}
class BluetoothError extends BluetoothState {
  final String message;
  BluetoothError(this.message);
}
