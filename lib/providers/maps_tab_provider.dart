import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evently/model/event.dart';
import 'package:evently/utils/firebase_utils.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsTabProvider extends ChangeNotifier {
  Location location = Location();
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  List<Event> eventsFiltered = [];
  List<Event> eventsList = [];
  Event? event;

  // ✅ جلب جميع الأحداث من Firebase
  Future<void> getAllEvents(String uId) async {
    QuerySnapshot<Event> querySnapshot =
        await FirebaseUtils.getEventsCollection(uId).get();

    /// إضافة id لكل حدث من doc.id
    eventsList =
        querySnapshot.docs.map((doc) {
          Event e = doc.data();
          return e.copyWith(id: doc.id);
        }).toList();

    eventsFiltered = eventsList;
    eventsFiltered.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  /// ✅ فلترة الأحداث حسب التاب المختارة

  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<bool> _getLocationPermission() async {
    PermissionStatus permissionStatus;
    permissionStatus = await location.hasPermission();

    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
    }
    return permissionStatus == PermissionStatus.granted;
  }

  Future<void> getLocation() async {
    bool permissionGranted = await _getLocationPermission();
    if (!permissionGranted) {
      return;
    }
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    LocationData locationData = await location.getLocation();
    updateLocation(locationData, event?.title ?? 'Current Location');
    notifyListeners();
  }

  void updateLocation(LocationData locationData, String title) {
    cameraPosition = CameraPosition(
      target: LatLng(locationData.latitude!, locationData.longitude!),
      zoom: 14.4746,
    );

    markers.clear();

    markers.add(
      Marker(
        markerId: MarkerId(UniqueKey().toString()),
        position: LatLng(locationData.latitude!, locationData.longitude!),
        infoWindow: InfoWindow(title: title),
      ),
    );

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );

    notifyListeners();
  }
 
 String? countryName;
 String? cityName;
 
  Future<void> convertLatlang(LatLng latLng) async {

    
    List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );
    if (placemarks.isNotEmpty) {
      geo.Placemark placemark = placemarks.first;
      countryName = placemark.country??'Canot get country';
      cityName = placemark.locality??'Cannot get city';
    }
    notifyListeners();
  }

  }

  // void setLocationListener() {
  // location.onLocationChanged.listen((LocationData locationData) {
  //   location.changeSettings(interval: 5000, accuracy: LocationAccuracy.high);
  //   updateLocation(locationData);
  //   notifyListeners();
  // });

