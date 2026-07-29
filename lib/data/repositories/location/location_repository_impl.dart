import 'dart:async';

import 'package:evently/data/repositories/location/location_repository.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationRepositoryImpl implements LocationRepository {
  Location location = Location();
  @override
  Future<Map<String, String>> convertLatLng(LatLng latLng) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        geo.Placemark placemark = placemarks.first;

        String country = placemark.country ?? 'Unknown Country';
        String city =
            placemark.locality ??
            placemark.subAdministrativeArea ??
            'Unknown City';

        debugPrint('✅ Location converted: $city, $country');

        return {'city': city, 'country': country};

        // onLocationConverted(country, city);
      } else {
        debugPrint('⚠️ No placemarks found');
        // onLocationConverted('Unknown Country', 'Unknown City');
      }
    } catch (e) {
      debugPrint('❌ Error converting location: $e');
      // onError?.call(e.toString());
      // onLocationConverted('Error', 'Error');
    }
    return {'city': 'Unknown City', 'country': 'Unknown Country'};
  }

  @override
  Future<LocationData> getCurrentLocation() async {
    try {
      bool permissionGranted = await _getLocationPermission();
      if (!permissionGranted) {
        debugPrint('❌ Location permission denied');
        // onError?.call('Location permission denied');
        throw Exception('Location permission denied');
      }

      print(" ✅permission: $permissionGranted");
      debugPrint('🔍 Before serviceEnabled...');
      bool serviceEnabled = await location.serviceEnabled().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Location timeout'),
      );
      debugPrint("✅ serviceEnabled: $serviceEnabled");
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          debugPrint('❌ Location service not enabled');
          // onError?.call('Location service not enabled');
          throw Exception('Location service not enabled');
        }
      }

      debugPrint('🔍 Before getLocation...');
      LocationData locationData = await location.getLocation().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Location timeout'),
      );
      debugPrint('✅ After getLocation: ${locationData.latitude}');
      debugPrint(
        '✅ Location fetched: ${locationData.latitude}, ${locationData.longitude}',
      );
      return locationData;
      // onLocationFetched(locationData);
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      // onError?.call(e.toString());
      rethrow;
    }
  }

  Future<bool> _getLocationPermission() async {
    print("STEP 1: before hasPermission");

    PermissionStatus permissionStatus;
    permissionStatus = await location.hasPermission();

    print("STEP 2: after hasPermission: $permissionStatus");

    if (permissionStatus == PermissionStatus.denied) {
      print("STEP 3: requesting permission...");
      permissionStatus = await location.requestPermission();
      print("STEP 4: after request: $permissionStatus");
    }

    print("STEP 5: final status: $permissionStatus");

    return permissionStatus == PermissionStatus.granted;
  }
  
}
