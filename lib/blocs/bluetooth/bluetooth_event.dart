part of 'bluetooth_bloc.dart';
abstract class BluetoothEvent {}
class BluetoothStartRequested extends BluetoothEvent {}
class BluetoothStopRequested extends BluetoothEvent {}
class BluetoothPayloadReceived extends BluetoothEvent {
  final List<int> bytes;
  BluetoothPayloadReceived(this.bytes);
}
