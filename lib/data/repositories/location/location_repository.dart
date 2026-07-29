import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

abstract class LocationRepository {
  Future<LocationData> getCurrentLocation();
  Future<Map<String, String>> convertLatLng(LatLng latLng);
}
