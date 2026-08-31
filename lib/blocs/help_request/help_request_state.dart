part of 'help_request_bloc.dart';

abstract class HelpRequestState {}

class HelpRequestInitial extends HelpRequestState {}

class HelpRequestLoading extends HelpRequestState {}

class HelpRequestSubmitted extends HelpRequestState {
  final String requestToken;
  HelpRequestSubmitted(this.requestToken);
}

class HelpRequestStatusLoaded extends HelpRequestState {
  final HelpRequestDetail detail;
  HelpRequestStatusLoaded(this.detail);
}

class HelpRequestsLoaded extends HelpRequestState {
  final List<HelpRequestDetail> requests;
  HelpRequestsLoaded(this.requests);
}

class HelpRequestAccepting extends HelpRequestState {}

class HelpRequestAccepted extends HelpRequestState {}

class HelpRequestAlreadyTaken extends HelpRequestState {}

class HelpRequestError extends HelpRequestState {
  final String message;
  HelpRequestError(this.message);
}