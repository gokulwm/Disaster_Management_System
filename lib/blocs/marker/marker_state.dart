part of 'marker_bloc.dart';

abstract class MarkerState {}

class MarkerInitial extends MarkerState {}

class MarkerLoading extends MarkerState {}

class MarkerLoaded extends MarkerState {
  final List<MarkerModel> markers;
  MarkerLoaded(this.markers);
}

class MarkerAdding extends MarkerState {}

class MarkerAdded extends MarkerState {}

class MarkerError extends MarkerState {
  final String message;
  MarkerError(this.message);
}