import 'package:flutter_bloc/flutter_bloc.dart';
part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc() : super(ConnectivityState(ConnectivityStatus.online)) {
    on<ConnectivityChanged>((event, emit) {
      emit(ConnectivityState(event.status));
    });
    on<ConnectivityCheckRequested>((event, emit) {
      emit(ConnectivityState(ConnectivityStatus.online));
    });
  }
}
