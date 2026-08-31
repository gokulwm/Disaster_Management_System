import 'package:flutter_bloc/flutter_bloc.dart';
part 'bluetooth_event.dart';
part 'bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  BluetoothBloc() : super(BluetoothInitial()) {
    on<BluetoothStartRequested>((event, emit) async {
      emit(BluetoothDiscovering([]));
    });
    on<BluetoothStopRequested>((event, emit) {
      emit(BluetoothInitial());
    });
    on<BluetoothPayloadReceived>((event, emit) {
      emit(BluetoothSyncing());
    });
  }
}
