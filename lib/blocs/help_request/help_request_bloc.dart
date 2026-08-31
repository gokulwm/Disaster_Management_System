import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disaster_link/data/models/help_request_detail.dart';
import 'package:disaster_link/data/repositories/help_request_repository.dart';

part 'help_request_event.dart';
part 'help_request_state.dart';

class HelpRequestBloc extends Bloc<HelpRequestEvent, HelpRequestState> {
  final HelpRequestRepository _repository = HelpRequestRepository();

  HelpRequestBloc() : super(HelpRequestInitial()) {
    on<HelpRequestSubmitRequested>(_onSubmit);
    on<HelpRequestStatusRequested>(_onGetStatus);
    on<HelpRequestsFetchRequested>(_onFetchPending);
    on<HelpRequestAcceptRequested>(_onAccept);
    on<HelpRequestsSubscribeRequested>(_onSubscribe);
  }

  Future<void> _onSubmit(
    HelpRequestSubmitRequested event,
    Emitter<HelpRequestState> emit,
  ) async {
    emit(HelpRequestLoading());
    try {
      final token = await _repository.submitRequest(
        name: event.name,
        helpType: event.helpType,
        lat: event.lat,
        lng: event.lng,
        description: event.description,
      );
      emit(HelpRequestSubmitted(token));
    } catch (e) {
      emit(HelpRequestError(e.toString()));
    }
  }

  Future<void> _onGetStatus(
    HelpRequestStatusRequested event,
    Emitter<HelpRequestState> emit,
  ) async {
    emit(HelpRequestLoading());
    try {
      final detail = await _repository.getMyRequest(event.token);
      if (detail != null) {
        emit(HelpRequestStatusLoaded(detail));
      } else {
        emit(HelpRequestError('Request not found'));
      }
    } catch (e) {
      emit(HelpRequestError(e.toString()));
    }
  }

  Future<void> _onFetchPending(
    HelpRequestsFetchRequested event,
    Emitter<HelpRequestState> emit,
  ) async {
    emit(HelpRequestLoading());
    try {
      final requests = await _repository.getPendingRequests(event.lat, event.lng);
      emit(HelpRequestsLoaded(requests));
    } catch (e) {
      emit(HelpRequestError(e.toString()));
    }
  }

  Future<void> _onAccept(
    HelpRequestAcceptRequested event,
    Emitter<HelpRequestState> emit,
  ) async {
    emit(HelpRequestAccepting());
    try {
      final success = await _repository.acceptRequest(event.requestId);
      if (success) {
        emit(HelpRequestAccepted());
      } else {
        // Race condition: another volunteer already accepted
        emit(HelpRequestAlreadyTaken());
      }
    } catch (e) {
      emit(HelpRequestError(e.toString()));
    }
  }

  Future<void> _onSubscribe(
    HelpRequestsSubscribeRequested event,
    Emitter<HelpRequestState> emit,
  ) async {
    // Realtime subscription is managed at the repository level
  }
}