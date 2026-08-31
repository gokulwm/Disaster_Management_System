import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disaster_link/data/models/marker.dart';
import 'package:disaster_link/data/repositories/marker_repository.dart';

part 'marker_event.dart';
part 'marker_state.dart';

class MarkerBloc extends Bloc<MarkerEvent, MarkerState> {
  final MarkerRepository _repository = MarkerRepository();

  MarkerBloc() : super(MarkerInitial()) {
    on<MarkersFetchRequested>(_onFetch);
    on<MarkerAddRequested>(_onAdd);
    on<MarkersSubscribeRequested>(_onSubscribe);
  }

  Future<void> _onFetch(
    MarkersFetchRequested event,
    Emitter<MarkerState> emit,
  ) async {
    emit(MarkerLoading());
    try {
      final markers = await _repository.fetchNearbyMarkers(event.lat, event.lng);
      emit(MarkerLoaded(markers));
    } catch (e) {
      emit(MarkerError(e.toString()));
    }
  }

  Future<void> _onAdd(
    MarkerAddRequested event,
    Emitter<MarkerState> emit,
  ) async {
    emit(MarkerAdding());
    try {
      await _repository.addMarker(event.marker);
      emit(MarkerAdded());
    } catch (e) {
      emit(MarkerError(e.toString()));
    }
  }

  Future<void> _onSubscribe(
    MarkersSubscribeRequested event,
    Emitter<MarkerState> emit,
  ) async {
    // Realtime subscription handled via repository stream
    await emit.forEach(
      _repository.subscribeToMarkers(),
      onData: (markers) => MarkerLoaded(markers),
      onError: (e, _) => MarkerError(e.toString()),
    );
  }
}