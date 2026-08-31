part of 'help_request_bloc.dart';
abstract class HelpRequestEvent {}
class HelpRequestSubmitRequested extends HelpRequestEvent {
  final String name, helpType, description;
  final double lat, lng;
  HelpRequestSubmitRequested(this.name, this.helpType, this.lat, this.lng, this.description);
}
class HelpRequestStatusRequested extends HelpRequestEvent {
  final String token;
  HelpRequestStatusRequested(this.token);
}
class HelpRequestAcceptRequested extends HelpRequestEvent {
  final String requestId;
  HelpRequestAcceptRequested(this.requestId);
}
class HelpRequestsFetchRequested extends HelpRequestEvent {
  final double lat, lng;
  HelpRequestsFetchRequested(this.lat, this.lng);
}
class HelpRequestsSubscribeRequested extends HelpRequestEvent {}
