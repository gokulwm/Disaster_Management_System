part of 'marker_bloc.dart';

abstract class MarkerEvent {}

class MarkersFetchRequested extends MarkerEvent {
  final double lat;
  final double lng;
  MarkersFetchRequested(this.lat, this.lng);
}

class MarkerAddRequested extends MarkerEvent {
  final MarkerModel marker;
  MarkerAddRequested(this.marker);
}

class MarkersSubscribeRequested extends MarkerEvent {}