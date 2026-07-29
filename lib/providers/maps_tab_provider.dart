// ═══════════════════════════════════════════════════════════
// 📄 maps_tab_provider.dart
// ═══════════════════════════════════════════════════════════

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evently/data/repositories/event_repository.dart';
import 'package:evently/domain/model/event.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'event_list_provider.dart';

class MapsTabProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════
  // 📍 المتغيرات الأساسية
  // ═══════════════════════════════════════════════════════════
  Location location = Location();
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Event? event;

  // ═══════════════════════════════════════════════════════════
  // 🏠 متغيرات موقع المستخدم الحقيقي (للـ Home Tab)
  // ═══════════════════════════════════════════════════════════
  String? userCountryName;
  String? userCityName;

  // ═══════════════════════════════════════════════════════════
  // 📌 متغيرات موقع الحدث المختار (للـ Map Tab)
  // ═══════════════════════════════════════════════════════════
  String? selectedEventCountryName;
  String? selectedEventCityName;

  // ✅✅✅ إضافة جديدة 1: Cache Map لتخزين مواقع الأحداث
  // ═══════════════════════════════════════════════════════════
  final Map<String, Map<String, String>> _eventLocationsCache = {};

  // ═══════════════════════════════════════════════════════════
  // 🔗 ربط مع EventListProvider
  // ═══════════════════════════════════════════════════════════
  final EventListProvider eventListProvider;
  List<Event> get eventsList => eventListProvider.eventsList;
  List<Event> get eventsFiltered => eventListProvider.eventsFiltered;

  final StreamController<List<Event>> _eventsStreamController =
      StreamController<List<Event>>.broadcast();

  Stream<List<Event>> get eventsStream => _eventsStreamController.stream;
  StreamSubscription<QuerySnapshot<Event>>? _firestoreSubscription;

  // ═══════════════════════════════════════════════════════════
  // 🏗️ Constructor
  // ═══════════════════════════════════════════════════════════
  MapsTabProvider(this.eventListProvider) {
    eventListProvider.addListener(_syncMapData);
  }

  // ═══════════════════════════════════════════════════════════
  // 🗺️ موقع الكاميرا الافتراضي
  // ═══════════════════════════════════════════════════════════
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // ═══════════════════════════════════════════════════════════
  // 🔄 مزامنة البيانات
  // ═══════════════════════════════════════════════════════════
  void _syncMapData() {
    _eventsStreamController.add(eventListProvider.eventsFiltered);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  // 🎧 الاستماع لتحديثات Firebase
  // ═══════════════════════════════════════════════════════════
  void trackEventUpdates(String uId) {
    _syncMapData();
    _firestoreSubscription?.cancel();

    _firestoreSubscription = EventRepository()
        .getEventsCollection(uId)
        .snapshots()
        .listen(
          (QuerySnapshot<Event> snapshot) {
            eventListProvider.updateEventsFromSnapshot(snapshot);
            _syncMapData();
          },
          onError: (error) {
            debugPrint('❌ Firestore subscription error: $error');
            _firestoreSubscription?.cancel();
            _firestoreSubscription = null;
          },
        );
  }

  // ═══════════════════════════════════════════════════════════
  // 🔐 طلب إذن الموقع
  // ═══════════════════════════════════════════════════════════
  Future<bool> _getLocationPermission() async {
    PermissionStatus permissionStatus;
    permissionStatus = await location.hasPermission();

    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
    }
    return permissionStatus == PermissionStatus.granted;
  }

  // ═══════════════════════════════════════════════════════════
  // 📍 دالة عامة #1: الحصول على الموقع الحالي (General)
  // ═══════════════════════════════════════════════════════════
  Future<void> currentLocation(
    Function(LocationData locationData) onLocationFetched, {
    Function(String error)? onError,
  }) async {
    try {
      bool permissionGranted = await _getLocationPermission();
      if (!permissionGranted) {
        debugPrint('❌ Location permission denied');
        onError?.call('Location permission denied');
        return;
      }

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          debugPrint('❌ Location service not enabled');
          onError?.call('Location service not enabled');
          return;
        }
      }

      LocationData locationData = await location.getLocation();

      debugPrint(
        '✅ Location fetched: ${locationData.latitude}, ${locationData.longitude}',
      );

      onLocationFetched(locationData);
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      onError?.call(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🌍 دالة عامة #2: تحويل الإحداثيات إلى معلومات مكان (General)
  // ═══════════════════════════════════════════════════════════
  Future<void> convertLatlang(
    LatLng latLng,
    Function(String country, String city) onLocationConverted, {
    Function(String error)? onError,
  }) async {
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

        onLocationConverted(country, city);
      } else {
        debugPrint('⚠️ No placemarks found');
        onLocationConverted('Unknown Country', 'Unknown City');
      }
    } catch (e) {
      debugPrint('❌ Error converting location: $e');
      onError?.call(e.toString());
      onLocationConverted('Error', 'Error');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🗺️ دالة عامة #3: تحديث موقع الخريطة (General)
  // ═══════════════════════════════════════════════════════════
  Future<void> setLocation(
    LatLng latLng, {
    String? title,
    Function()? onLocationSet,
  }) async {
    try {
      cameraPosition = CameraPosition(
        target: LatLng(latLng.latitude, latLng.longitude),
        zoom: 14.4746,
      );

      markers.clear();

      markers.add(
        Marker(
          markerId: MarkerId(UniqueKey().toString()),
          position: LatLng(latLng.latitude, latLng.longitude),
          infoWindow: InfoWindow(title: title ?? 'Selected Location'),
        ),
      );

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );

      debugPrint('✅ Location set: ${latLng.latitude}, ${latLng.longitude}');

      notifyListeners();

      onLocationSet?.call();
    } catch (e) {
      debugPrint('❌ Error setting location: $e');
    }
  }

  // ✅✅✅ إضافة جديدة 2: دالة جلب موقع حدث معين مع Cache
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, String>> getEventLocation(Event event) async {
    // ✅ 1. إذا كان الموقع مخزن مسبقًا، نرجعه مباشرة
    if (_eventLocationsCache.containsKey(event.id)) {
      debugPrint('✅ Cache hit for event: ${event.id}');
      return _eventLocationsCache[event.id]!;
    }

    // ✅ 2. إذا لم يكن مخزن، نجلبه من Geocoding
    debugPrint('🔄 Fetching location for event: ${event.id}');

    if (event.latitude == null || event.longitude == null) {
      return {'city': 'Unknown', 'country': 'Location'};
    }

    // ✅ 3. استخدام الدالة العامة الموجودة
    String city = 'Loading...';
    String country = 'Loading...';

    await convertLatlang(
      LatLng(event.latitude!, event.longitude!),
      (fetchedCountry, fetchedCity) {
        city = fetchedCity;
        country = fetchedCountry;

        // ✅ 4. حفظ النتيجة في الـ Cache
        _eventLocationsCache[event.id] = {'city': city, 'country': country};

        debugPrint('✅ Cached location for ${event.id}: $city, $country');
      },
      onError: (error) {
        city = 'Error';
        country = 'Error';
      },
    );

    return {'city': city, 'country': country};
  }

  // ✅✅✅ إضافة جديدة 3: دالة لمسح الـ Cache (اختيارية)
  // ═══════════════════════════════════════════════════════════
  void clearLocationCache() {
    _eventLocationsCache.clear();
    debugPrint('🗑️ Location cache cleared');
  }

  // ═══════════════════════════════════════════════════════════
  // 🎯 دالة مركبة #1: للـ Floating Action Button
  // ═══════════════════════════════════════════════════════════
  Future<void> floatingActionButtonLocation() async {
    debugPrint('🔘 FAB pressed - Getting current location...');

    await currentLocation(
      (locationData) {
        setLocation(
          LatLng(locationData.latitude!, locationData.longitude!),
          title: 'Your Current Location',
          onLocationSet: () {
            debugPrint('✅ FAB: Map updated successfully');
          },
        );
      },
      onError: (error) {
        debugPrint('❌ FAB Error: $error');
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🎯 دالة مركبة #2: تحويل وتحديث موقع الحدث
  // ═══════════════════════════════════════════════════════════
  Future<void> convertLatlangAndSetLocation(LatLng latLng, String title) async {
    debugPrint('📍 Setting event location: $title');

    await setLocation(
      latLng,
      title: title,
      onLocationSet: () {
        debugPrint('✅ Event location set on map');
      },
    );

    await convertLatlang(
      latLng,
      (country, city) {
        selectedEventCountryName = country;
        selectedEventCityName = city;

        debugPrint('✅ Event location converted: $city, $country');

        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Error converting event location: $error');
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🎯 دالة مركبة #3: الحصول على الموقع الحالي للمستخدم
  // ═══════════════════════════════════════════════════════════
  Future<void> getCurrentLocation() async {
    debugPrint('🏠 Getting user current location...');

    await currentLocation(
      (locationData) {
        convertLatlang(
          LatLng(locationData.latitude!, locationData.longitude!),
          (country, city) {
            userCountryName = country;
            userCityName = city;

            debugPrint('✅ User location: $city, $country');

            notifyListeners();
          },
          onError: (error) {
            debugPrint('❌ Error converting user location: $error');
          },
        );
      },
      onError: (error) {
        debugPrint('❌ Error getting user location: $error');
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🧹 تنظيف الموارد
  // ═══════════════════════════════════════════════════════════

  void cancelSubscription() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
  }

  @override
  void dispose() {
    eventListProvider.removeListener(_syncMapData);
    _firestoreSubscription?.cancel();
    _eventsStreamController.close();
    super.dispose();
  }
}
