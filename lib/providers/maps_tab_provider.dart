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


// ==═══════════════════════════════════════════════════════════

// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:evently/data/repositories/event_repository.dart';
// import 'package:evently/domain/model/event.dart';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart' as geo;
// import 'package:location/location.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'event_list_provider.dart';

// class MapsTabProvider extends ChangeNotifier {
//   // ═══════════════════════════════════════════════════════════
//   // 📍 المتغيرات الأساسية
//   // ═══════════════════════════════════════════════════════════
//   Location location = Location();
//   GoogleMapController? mapController;
//   Set<Marker> markers = {};
//   Event? event;



//   // ═══════════════════════════════════════════════════════════
//   // 🏠 متغيرات موقع المستخدم الحقيقي (للـ Home Tab)
//   // ═══════════════════════════════════════════════════════════
//   String? userCountryName;
//   String? userCityName;

//   // ═══════════════════════════════════════════════════════════
//   // 📌 متغيرات موقع الحدث المختار (للـ Map Tab)
//   // ═══════════════════════════════════════════════════════════
//   String? selectedEventCountryName;
//   String? selectedEventCityName;

//   // ═══════════════════════════════════════════════════════════
//   // 🔗 ربط مع EventListProvider
//   // ═══════════════════════════════════════════════════════════
//   final EventListProvider eventListProvider;
//   List<Event> get eventsList => eventListProvider.eventsList;
//   List<Event> get eventsFiltered => eventListProvider.eventsFiltered;

//   final StreamController<List<Event>> _eventsStreamController =
//       StreamController<List<Event>>.broadcast();

//   Stream<List<Event>> get eventsStream => _eventsStreamController.stream;
//   StreamSubscription<QuerySnapshot<Event>>? _firestoreSubscription;

//   // ═══════════════════════════════════════════════════════════
//   // 🏗️ Constructor
//   // ═══════════════════════════════════════════════════════════
//   MapsTabProvider(this.eventListProvider) {
//     eventListProvider.addListener(_syncMapData);
//   }

//   // ═══════════════════════════════════════════════════════════
//   // 🗺️ موقع الكاميرا الافتراضي
//   // ═══════════════════════════════════════════════════════════
//   CameraPosition cameraPosition = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );

//   // ═══════════════════════════════════════════════════════════
//   // 🔄 مزامنة البيانات
//   // ═══════════════════════════════════════════════════════════
//   void _syncMapData() {
//     _eventsStreamController.add(eventListProvider.eventsFiltered);
//     notifyListeners();
//   }

//   // ═══════════════════════════════════════════════════════════
//   // 🎧 الاستماع لتحديثات Firebase
//   // ═══════════════════════════════════════════════════════════
//   void trackEventUpdates(String uId) {
//     _syncMapData();
//     _firestoreSubscription?.cancel();

//     _firestoreSubscription = EventRepository()
//         .getEventsCollection(uId)
//         .snapshots()
//         .listen((QuerySnapshot<Event> snapshot) {
//           eventListProvider.updateEventsFromSnapshot(snapshot);
//           _syncMapData();
//         });
//   }

//   // ═══════════════════════════════════════════════════════════
//   // 🔐 طلب إذن الموقع
//   // ═══════════════════════════════════════════════════════════
//   Future<bool> _getLocationPermission() async {
//     // ✅ 1. التحقق من حالة الإذن الحالية
//     PermissionStatus permissionStatus;
//     permissionStatus = await location.hasPermission();

//     // ✅ 2. إذا كان الإذن مرفوض، نطلبه من المستخدم
//     if (permissionStatus == PermissionStatus.denied) {
//       permissionStatus = await location.requestPermission();
//     }

//     // ✅ 3. نرجع true لو الإذن متاح، false لو مرفوض
//     return permissionStatus == PermissionStatus.granted;
//   }

//   // ═══════════════════════════════════════════════════════════
//   // 📍 دالة عامة #1: الحصول على الموقع الحالي (General)
//   // ═══════════════════════════════════════════════════════════
//   /// دالة عامة للحصول على موقع المستخدم الحالي
//   ///
//   /// Parameters:
//   /// - onLocationFetched: callback يتم تنفيذه بعد الحصول على الموقع
//   ///   يأخذ LocationData كـ parameter
//   /// - onError: (optional) callback يتم تنفيذه في حالة حدوث خطأ

//   Future<void> currentLocation(
//     Function(LocationData locationData) onLocationFetched, {
//     Function(String error)? onError,
//   }) async {
//     try {
//       // ✅ 1. طلب إذن الموقع
//       bool permissionGranted = await _getLocationPermission();
//       if (!permissionGranted) {
//         debugPrint('❌ Location permission denied');
//         onError?.call('Location permission denied');
//         return;
//       }

//       // ✅ 2. التحقق من تفعيل خدمة الموقع
//       bool serviceEnabled = await location.serviceEnabled();
//       if (!serviceEnabled) {
//         serviceEnabled = await location.requestService();
//         if (!serviceEnabled) {
//           debugPrint('❌ Location service not enabled');
//           onError?.call('Location service not enabled');
//           return;
//         }
//       }

//       // ✅ 3. الحصول على الموقع الحالي
//       LocationData locationData = await location.getLocation();

//       debugPrint(
//         '✅ Location fetched: ${locationData.latitude}, ${locationData.longitude}',
//       );

//       // ✅ 4. تنفيذ الـ callback مع بيانات الموقع
//       onLocationFetched(locationData);
//     } catch (e) {
//       // ✅ 5. معالجة الأخطاء
//       debugPrint('❌ Error getting location: $e');
//       onError?.call(e.toString());
//     }
//   }

//   // ═══════════════════════════════════════════════════════════
//   // 🌍 دالة عامة #2: تحويل الإحداثيات إلى معلومات مكان (General)
//   // ═══════════════════════════════════════════════════════════
//   /// دالة عامة لتحويل الإحداثيات (LatLng) إلى اسم المدينة والبلد
//   ///
//   /// Parameters:
//   /// - latLng: الإحداثيات المراد تحويلها
//   /// - onLocationConverted: callback يتم تنفيذه بعد التحويل
//   ///   يأخذ (country, city) كـ parameters
//   /// - onError: (optional) callback يتم تنفيذه في حالة حدوث خطأ

//   Future<void> convertLatlang(
//     LatLng latLng,
//     Function(String country, String city) onLocationConverted, {
//     Function(String error)? onError,
//   }) async {
//     try {
//       // ✅ 1. استدعاء خدمة Geocoding لتحويل الإحداثيات
//       List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
//         latLng.latitude,
//         latLng.longitude,
//       );

//       // ✅ 2. التحقق من وجود نتائج
//       if (placemarks.isNotEmpty) {
//         geo.Placemark placemark = placemarks.first;

//         // ✅ 3. استخراج اسم البلد والمدينة
//         String country = placemark.country ?? 'Unknown Country';
//         String city =
//             placemark.locality ??
//             placemark.subAdministrativeArea ??
//             'Unknown City';

//         debugPrint('✅ Location converted: $city, $country');

//         // ✅ 4. تنفيذ الـ callback مع البيانات المحولة
//         onLocationConverted(country, city);
//       } else {
//         // ✅ 5. في حالة عدم وجود نتائج
//         debugPrint('⚠️ No placemarks found');
//         onLocationConverted('Unknown Country', 'Unknown City');
//       }
//     } catch (e) {
//       // ✅ 6. معالجة الأخطاء
//       debugPrint('❌ Error converting location: $e');
//       onError?.call(e.toString());
//       onLocationConverted('Error', 'Error');
//     }
//   }

//   // ═══════════════════════════════════════════════════════════
//   // 🗺️ دالة عامة #3: تحديث موقع الخريطة (General)
//   // ═══════════════════════════════════════════════════════════
//   /// دالة عامة لتحديث موقع الخريطة وإضافة علامة
//   ///
//   /// Parameters:
//   /// - latLng: الإحداثيات المراد التحرك إليها
//   /// - title: عنوان العلامة (optional)
//   /// - onLocationSet: callback يتم تنفيذه بعد تحديث الموقع

//   Future<void> setLocation(
//     LatLng latLng, {
//     String? title,
//     Function()? onLocationSet,
//   }) async {
//     try {
//       // ✅ 1. تحديث موقع الكاميرا
//       cameraPosition = CameraPosition(
//         target: LatLng(latLng.latitude, latLng.longitude),
//         zoom: 14.4746,
//       );

//       // ✅ 2. مسح العلامات القديمة
//       markers.clear();

//       // ✅ 3. إضافة علامة جديدة في الموقع المحدد
//       markers.add(
//         Marker(
//           markerId: MarkerId(UniqueKey().toString()),
//           position: LatLng(latLng.latitude, latLng.longitude),
//           infoWindow: InfoWindow(title: title ?? 'Selected Location'),
//         ),
//       );

//       // ✅ 4. تحريك الكاميرا إلى الموقع الجديد (مع animation)
//       mapController?.animateCamera(
//         CameraUpdate.newCameraPosition(cameraPosition),
//       );

//       debugPrint('✅ Location set: ${latLng.latitude}, ${latLng.longitude}');

//       // ✅ 5. إخطار المستمعين بالتحديث
//       notifyListeners();

//       // ✅ 6. تنفيذ الـ callback (إن وجد)
//       onLocationSet?.call();
//     } catch (e) {
//       debugPrint('❌ Error setting location: $e');
//     }
//   }

//   // ═══════════════════════════════════════════════════════════
//   // 🎯 دالة مركبة #1: للـ Floating Action Button
//   // ═══════════════════════════════════════════════════════════
//   /// دالة للحصول على الموقع الحالي وتحديث الخريطة
//   /// تُستخدم عند الضغط على زر الـ FAB
//   ///
//   /// تستخدم الدوال العامة:
//   /// 1. currentLocation() - للحصول على الموقع
//   /// 2. setLocation() - لتحديث الخريطة

//   // ✅
//   Future<void> floatingActionButtonLocation() async {
//     debugPrint('🔘 FAB pressed - Getting current location...');

//     // ✅ 1. استخدام الدالة العامة للحصول على الموقع
//     await currentLocation(
//       (locationData) {
//         // ✅ 2. عند الحصول على الموقع، نحدث الخريطة
//         setLocation(
//           LatLng(locationData.latitude!, locationData.longitude!),
//           title: 'Your Current Location',
//           onLocationSet: () {
//             debugPrint('✅ FAB: Map updated successfully');
//           },
//         );
//       },
//       onError: (error) {
//         debugPrint('❌ FAB Error: $error');
//       },
//     );
//   }

//   // ═══════════════════════════════════════════════════════════
//   // 🎯 دالة مركبة #2: تحويل وتحديث موقع الحدث
//   // ═══════════════════════════════════════════════════════════
//   /// دالة لتحديث الخريطة بموقع حدث معين مع تحويل الإحداثيات
//   /// تُستخدم عند الضغط على حدث في القائمة
//   ///
//   /// تستخدم الدوال العامة:
//   /// 1. setLocation() - لتحديث الخريطة
//   /// 2. convertLatlang() - لتحويل الإحداثيات
//   ///
//   /// Parameters:
//   /// - latLng: إحداثيات الحدث
//   /// - title: عنوان الحدث

//   // ✅
//   Future<void> convertLatlangAndSetLocation(LatLng latLng, String title) async {
//     debugPrint('📍 Setting event location: $title');

//     // ✅ 1. أولاً نحدث موقع الخريطة
//     await setLocation(
//       latLng,
//       title: title,
//       onLocationSet: () {
//         debugPrint('✅ Event location set on map');
//       },
//     );

//     // ✅ 2. ثم نحول الإحداثيات لاسم مدينة وبلد
//     await convertLatlang(
//       latLng,
//       (country, city) {
//         // ✅ 3. نحفظ البيانات في متغيرات الحدث المختار
//         selectedEventCountryName = country;
//         selectedEventCityName = city;

//         debugPrint('✅ Event location converted: $city, $country');

//         // ✅ 4. إخطار المستمعين
//         notifyListeners();
//       },
//       onError: (error) {
//         debugPrint('❌ Error converting event location: $error');
//       },
//     );
//   }

//   // ═══════════════════════════════════════════════════════════
//   // 🎯 دالة مركبة #3: الحصول على الموقع الحالي للمستخدم
//   // ═══════════════════════════════════════════════════════════
//   /// دالة للحصول على الموقع الحقيقي للمستخدم وحفظه
//   /// تُستخدم في Home Tab عند تحميل التطبيق
//   ///
//   /// تستخدم الدوال العامة:
//   /// 1. currentLocation() - للحصول على الموقع
//   /// 2. setLocation() - لتحديث الخريطة
//   /// 3. convertLatlang() - لتحويل الإحداثيات

//   Future<void> getCurrentLocation() async {
//     debugPrint('🏠 Getting user current location...');

//     // ✅ 1. الحصول على الموقع الحالي
//     await currentLocation(
//       (locationData) {
//         // ✅ 3. تحويل الإحداثيات لاسم مدينة وبلد
//         convertLatlang(
//           LatLng(locationData.latitude!, locationData.longitude!),
//           (country, city) {
//             // ✅ 4. حفظ البيانات في متغيرات المستخدم (للـ Home Tab)
//             userCountryName = country;
//             userCityName = city;

//             debugPrint('✅ User location: $city, $country');

//             // ✅ 5. إخطار المستمعين
//             notifyListeners();
//           },
//           onError: (error) {
//             debugPrint('❌ Error converting user location: $error');
//           },
//         );
//       },
//       onError: (error) {
//         debugPrint('❌ Error getting user location: $error');
//       },
//     );
//   }

//   // ═══════════════════════════════════════════════════════════
//   // 🧹 تنظيف الموارد
//   // ═══════════════════════════════════════════════════════════
//   @override
//   void dispose() {
//     // ✅ 1. إلغاء الاستماع لتغييرات EventListProvider
//     eventListProvider.removeListener(_syncMapData);

//     // ✅ 2. إلغاء الاشتراك في Firebase
//     _firestoreSubscription?.cancel();

//     // ✅ 3. إغلاق StreamController
//     _eventsStreamController.close();

//     // ✅ 4. استدعاء dispose للـ parent class
//     super.dispose();
//   }
// }


// // =══════════════════════════════════════════════════════════

// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:evently/data/repositories/event_repository.dart';
// // import 'package:evently/domain/model/event.dart';
// // import 'package:flutter/material.dart';
// // import 'package:geocoding/geocoding.dart' as geo;
// // import 'package:location/location.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'event_list_provider.dart';

// // class MapsTabProvider extends ChangeNotifier {
// //   // ═══════════════════════════════════════════════════════════
// //   // 📍 المتغيرات الأساسية
// //   // ═══════════════════════════════════════════════════════════
  
// //   Location location = Location();
// //   GoogleMapController? mapController;
// //   Set<Marker> markers = {};
// //   Event? event;
  
// //   // ═══════════════════════════════════════════════════════════
// //   // 🏠 متغيرات موقع المستخدم الحقيقي (للـ Home Tab)
// //   // ═══════════════════════════════════════════════════════════
// //   String? userCountryName;
// //   String? userCityName;
  
// //   // ═══════════════════════════════════════════════════════════
// //   // 📌 متغيرات موقع الحدث المختار (للـ Map Tab)
// //   // ═══════════════════════════════════════════════════════════
// //   String? selectedEventCountryName;
// //   String? selectedEventCityName;
  
// //   // ═══════════════════════════════════════════════════════════
// //   // 🔗 ربط مع EventListProvider
// //   // ═══════════════════════════════════════════════════════════
// //   final EventListProvider eventListProvider;
// //   List<Event> get eventsList => eventListProvider.eventsList;
// //   List<Event> get eventsFiltered => eventListProvider.eventsFiltered;

// //   final StreamController<List<Event>> _eventsStreamController =
// //       StreamController<List<Event>>.broadcast();

// //   Stream<List<Event>> get eventsStream => _eventsStreamController.stream;
// //   StreamSubscription<QuerySnapshot<Event>>? _firestoreSubscription;

// //   // ═══════════════════════════════════════════════════════════
// //   // 🏗️ Constructor
// //   // ═══════════════════════════════════════════════════════════
// //   MapsTabProvider(this.eventListProvider) {
// //     eventListProvider.addListener(_syncMapData);
// //   }

// //   // ═══════════════════════════════════════════════════════════
// //   // 🗺️ موقع الكاميرا الافتراضي
// //   // ═══════════════════════════════════════════════════════════
// //   CameraPosition cameraPosition = CameraPosition(
// //     target: LatLng(37.42796133580664, -122.085749655962),
// //     zoom: 14.4746,
// //   );

// //   // ═══════════════════════════════════════════════════════════
// //   // 🔄 مزامنة البيانات
// //   // ═══════════════════════════════════════════════════════════
// //   void _syncMapData() {
// //     _eventsStreamController.add(eventListProvider.eventsFiltered);
// //     notifyListeners();
// //   }

// //   // ═══════════════════════════════════════════════════════════
// //   // 🎧 الاستماع لتحديثات Firebase
// //   // ═══════════════════════════════════════════════════════════
// //   void trackEventUpdates(String uId) {
// //     _syncMapData();
// //     _firestoreSubscription?.cancel();

// //     _firestoreSubscription = EventRepository()
// //         .getEventsCollection(uId)
// //         .snapshots()
// //         .listen((QuerySnapshot<Event> snapshot) {
// //           eventListProvider.updateEventsFromSnapshot(snapshot);
// //           _syncMapData();
// //         });
// //   }

// //   // ═══════════════════════════════════════════════════════════
// //   // 🔐 طلب إذن الموقع
// //   // ═══════════════════════════════════════════════════════════
// //   Future<bool> _getLocationPermission() async {
// //     PermissionStatus permissionStatus;
// //     permissionStatus = await location.hasPermission();

// //     if (permissionStatus == PermissionStatus.denied) {
// //       permissionStatus = await location.requestPermission();
// //     }
// //     return permissionStatus == PermissionStatus.granted;
// //   }

// //   // ═══════════════════════════════════════════════════════════
// //   // 🏠 دالة للحصول على موقع المستخدم الحقيقي
// //   // ═══════════════════════════════════════════════════════════
// //   Future<void> fetchCurrentLocation() async {
// //     // ✅ 1. طلب إذن الموقع
// //     bool permissionGranted = await _getLocationPermission();
// //     if (!permissionGranted) {
// //       debugPrint('❌ Location permission denied');
// //       return;
// //     }

// //     // ✅ 2. التحقق من تفعيل خدمة الموقع
// //     bool serviceEnabled = await location.serviceEnabled();
// //     if (!serviceEnabled) {
// //       serviceEnabled = await location.requestService();
// //       if (!serviceEnabled) {
// //         debugPrint('❌ Location service not enabled');
// //         return;
// //       }
// //     }

// //     // ✅ 3. الحصول على الموقع الحالي
// //     LocationData locationData = await location.getLocation();
    
// //     // ✅ 4. تحديث الخريطة بالموقع الجديد
// //     updateMapLocation(locationData, 'Your Current Location');
    
// //     // ✅ 5. تحويل الإحداثيات إلى اسم مدينة وبلد (للمستخدم فقط)
// //     await convertUserLocation(
// //       LatLng(locationData.latitude!, locationData.longitude!),
// //     );

// //     notifyListeners();
// //   }

// //   // ═══════════════════════════════════════════════════════════
// //   // 🌍 تحويل إحداثيات موقع المستخدم إلى اسم مدينة/بلد
// //   // ═══════════════════════════════════════════════════════════
// //   Future<void> convertUserLocation(LatLng latLng) async {
// //     try {
// //       // ✅ 1. استدعاء خدمة Geocoding
// //       List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
// //         latLng.latitude,
// //         latLng.longitude,
// //       );
      
// //       // ✅ 2. التحقق من وجود نتائج
// //       if (placemarks.isNotEmpty) {
// //         geo.Placemark placemark = placemarks.first;
        
// //         // ✅ 3. تحديث متغيرات المستخدم مباشرة (للـ Home Tab)
// //         userCountryName = placemark.country ?? 'Unknown Country';
// //         userCityName = placemark.locality ?? 
// //                        placemark.administrativeArea  ?? 
// //                        'Unknown City';
        
// //         debugPrint('✅ User Location: $userCityName, $userCountryName');
// //       }
// //     } catch (e) {
// //       debugPrint('❌ Error converting user location: $e');
// //       userCountryName = 'Error';
// //       userCityName = 'Error';
// //     }
    
// //     notifyListeners();
// //   }

// //   // ═══════════════════════════════════════════════════════════
// //   // 📍 تحويل إحداثيات الحدث المختار إلى اسم مدينة/بلد
// //   // ═══════════════════════════════════════════════════════════
// //   Future<void> convertEventLocation(LatLng latLng) async {
// //     try {
// //       // ✅ 1. استدعاء خدمة Geocoding
// //       List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
// //         latLng.latitude,
// //         latLng.longitude,
// //       );
      
// //       // ✅ 2. التحقق من وجود نتائج
// //       if (placemarks.isNotEmpty) {
// //         geo.Placemark placemark = placemarks.first;
        
// //         // ✅ 3. تحديث متغيرات الحدث المختار (للـ Map Tab)
// //         selectedEventCountryName = placemark.country ?? 'Unknown Country';
// //         selectedEventCityName = placemark.locality ?? 
// //                                 placemark.subAdministrativeArea ?? 
// //                                 'Unknown City';
        
// //         debugPrint('✅ Event Location: $selectedEventCityName, $selectedEventCountryName');
// //       }
// //     } catch (e) {
// //       debugPrint('❌ Error converting event location: $e');
// //       selectedEventCountryName = 'Error';
// //       selectedEventCityName = 'Error';
// //     }
    
// //     notifyListeners();
// //   }

// //   // ═══════════════════════════════════════════════════════════
// //   // 🗺️ تحديث موقع الخريطة والعلامات
// //   // ═══════════════════════════════════════════════════════════
// //   void updateMapLocation(LocationData locationData, String title) {
// //     // ✅ 1. تحديث موقع الكاميرا
// //     cameraPosition = CameraPosition(
// //       target: LatLng(locationData.latitude!, locationData.longitude!),
// //       zoom: 14.4746,
// //     );

// //     // ✅ 2. مسح العلامات القديمة
// //     markers.clear();

// //     // ✅ 3. إضافة علامة جديدة
// //     markers.add(
// //       Marker(
// //         markerId: MarkerId(UniqueKey().toString()),
// //         position: LatLng(locationData.latitude!, locationData.longitude!),
// //         infoWindow: InfoWindow(title: title),
// //       ),
// //     );

// //     // ✅ 4. تحريك الكاميرا
// //     mapController?.animateCamera(
// //       CameraUpdate.newCameraPosition(cameraPosition),
// //     );

// //     notifyListeners();
// //   }

// //   // ═══════════════════════════════════════════════════════════
// //   // 🧹 تنظيف الموارد
// //   // ═══════════════════════════════════════════════════════════
// //   @override
// //   void dispose() {
// //     eventListProvider.removeListener(_syncMapData);
// //     _firestoreSubscription?.cancel();
// //     _eventsStreamController.close();
// //     super.dispose();
// //   }
// // }



// // // ═══════════════════════════════════════════════════════════

