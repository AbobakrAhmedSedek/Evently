import 'package:google_maps_flutter/google_maps_flutter.dart';

sealed class LocationState {}
class LocationInitial extends LocationState {}
class LocationLoading extends LocationState {}
class LocationSuccess extends LocationState {
  final String? cityName;
  final String? countryName;
   LatLng? latLng;
  LocationSuccess( {this.cityName, this.countryName, this.latLng,    });
}
class LocationError extends LocationState {
  final String message;
  LocationError(this.message);
}