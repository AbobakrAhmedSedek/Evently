

import 'package:evently/domain/model/event.dart';
import 'package:evently/providers/event_list_provider.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:evently/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class AddEventProvider extends ChangeNotifier {
  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State Variables
  int selectedIndex = 0;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? formatTime;
  Location location = Location();
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  LatLng? eventLocation;

  // Image List
  final List<String> imageSelectedEventList = [
    AssetsManager.sportImage,
    AssetsManager.birthdayImage,
    AssetsManager.meetingImage,
    AssetsManager.gamingImage,
    AssetsManager.workshopImage,
    AssetsManager.bookClubImage,
    AssetsManager.exhibitionImage,
    AssetsManager.holidayImage,
    AssetsManager.eatingImage,
  ];

  // Getters
  String get selectedImage =>
      selectedIndex < imageSelectedEventList.length
          ? imageSelectedEventList[selectedIndex]
          : imageSelectedEventList[0];

  // ✅ دالة للتحقق من صلاحية الموقع
  bool isValidLocation(LatLng? location) {
    return location != null && 
           location.latitude != 0.0 && 
           location.longitude != 0.0 &&
           location.latitude.abs() <= 90 &&
           location.longitude.abs() <= 180;
  }

  // Methods
  void changeSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> chooseDate(BuildContext context) async {
    var chooseDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (chooseDate != null) {
      selectedDate = chooseDate;
      notifyListeners();
    }
  }

  Future<void> chooseTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      selectedTime = picked;
      formatTime = picked.format(context);
      notifyListeners();
    }
  }

  String getFormattedDate(BuildContext context) {
    if (selectedDate == null) {
      return AppLocalizations.of(context)!.choose_date;
    }
    return DateFormat("dd/MM/yyyy").format(selectedDate!);
  }

  String getFormattedTime(BuildContext context) {
    if (selectedTime == null) {
      return AppLocalizations.of(context)!.choose_time;
    }
    return selectedTime!.format(context);
  }

  // ✅ تحديث دالة إضافة الحدث مع Validation للموقع
  Future<void> updateEvent(
    BuildContext context,
    EventListProvider eventListProvider,
    UserProvider userProvider,
  ) async {
    // ✅ 1. التحقق من صحة النموذج
    if (formKey.currentState?.validate() != true) {
      return;
    }

    // ✅ 2. التحقق من التاريخ
    if (selectedDate == null) {
      ToastUtils.showToast(
        message: AppLocalizations.of(context)!.choose_date,
        backgroundColor: Colors.red,
      );
      return;
    }

    // ✅ 3. التحقق من الوقت
    if (selectedTime == null || formatTime == null) {
      ToastUtils.showToast(
        message: AppLocalizations.of(context)!.choose_time,
        backgroundColor: Colors.red, 
      );
      return;
    }

    // ✅ 4. التحقق من الموقع (إلزامي)
    if (!isValidLocation(eventLocation)) {
      ToastUtils.showToast(
        message: AppLocalizations.of(context)!.please_choose_location ,
        backgroundColor: Colors.red,
      );
      return;
    }

    // ✅ 5. التحقق من قائمة الأحداث
    if (eventListProvider.eventsDataList.isEmpty) {
      ToastUtils.showToast(
        message: "Error: Event categories not loaded",
        backgroundColor: Colors.red,
      );
      return;
    }

    // ✅ 6. التحقق من المستخدم
    String? userId = userProvider.user?.id;
    if (userId == null) {
      ToastUtils.showToast(
        message: "Please login first",
        backgroundColor: Colors.red,
      );
      return;
    }

    // ✅ 7. بناء الحدث
    int actualIndex = selectedIndex + 1;

    Event event = Event(
      category: eventListProvider.eventsDataList[actualIndex].categoryKey,
      image: selectedImage,
      description: descriptionController.text,
      title: titleController.text,
      date: selectedDate!,
      time: formatTime!,
      userId: userId,
      latitude: eventLocation!.latitude,   // ✅ بدون ?? 0.0
      longitude: eventLocation!.longitude, // ✅ بدون ?? 0.0
    );

    // ✅ 8. إضافة الحدث
    bool success = await eventListProvider.addEvent(event, userId);

    if (!context.mounted) return;

    // ✅ 9. عرض النتيجة
    if (success) {
      ToastUtils.showToast(
        message: AppLocalizations.of(context)!.event_added_successfully,
        backgroundColor: Colors.green,
      );
      
      // ✅ 10. تنظيف البيانات
      clearData();
      
      // ✅ 11. العودة للصفحة السابقة
      Navigator.pop(context);
    } else {
      ToastUtils.showToast(
        message: "Error adding event",
        backgroundColor: Colors.red,
      );
    }
  }

  void clearData() {
    selectedIndex = 0;
    selectedDate = null;
    selectedTime = null;
    formatTime = null;
    titleController.clear();
    descriptionController.clear();
    eventLocation = null;
    markers.clear();
    mapController = null;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    mapController?.dispose();
    super.dispose();
  }

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

    try {
      LocationData locationData = await location.getLocation();
      
      // ✅ التحقق من صلاحية الموقع قبل استخدامه
      if (locationData.latitude != null && 
          locationData.longitude != null &&
          locationData.latitude != 0.0 && 
          locationData.longitude != 0.0) {
        updateLocation(locationData);
      }
    } catch (e) {
      print('Error getting location: $e');
    }
    
    notifyListeners();
  }

  void updateLocation(LocationData locationData) {
    cameraPosition = CameraPosition(
      target: LatLng(locationData.latitude!, locationData.longitude!),
      zoom: 14.4746,
    );
    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId('current_location'),
        position: LatLng(locationData.latitude!, locationData.longitude!),
        infoWindow: InfoWindow(title: 'Current Location'),
      ),
    );

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );

    notifyListeners();
  }

  void setEventLocation(LatLng latLng) {
    eventLocation = latLng;
    markers.clear(); // ✅ مسح الـ markers القديمة
    markers.add(
      Marker(
        markerId: MarkerId('event_location'),
        position: latLng,
        infoWindow: InfoWindow(title: 'Event Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    notifyListeners();
  }
}

// ------------------------------------------------------------------------------
// import 'package:evently/domain/model/event.dart';
// import 'package:evently/providers/event_list_provider.dart';
// import 'package:evently/providers/user_provider.dart';
// import 'package:evently/utils/assets_manager.dart';
// import 'package:evently/utils/toast_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:location/location.dart';

// class AddEventProvider extends ChangeNotifier {
//   // Controllers
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();

//   // State Variables
//   int selectedIndex = 0;
//   DateTime? selectedDate;
//   TimeOfDay? selectedTime;
//   String? formatTime;
//   Location location = Location();
//   GoogleMapController? mapController;
//   Set<Marker> markers = {};
//   LatLng? eventLocation;

//   // Image List
//   final List<String> imageSelectedEventList = [
//     AssetsManager.sportImage,
//     AssetsManager.birthdayImage,
//     AssetsManager.meetingImage,
//     AssetsManager.gamingImage,
//     AssetsManager.workshopImage,
//     AssetsManager.bookClubImage,
//     AssetsManager.exhibitionImage,
//     AssetsManager.holidayImage,
//     AssetsManager.eatingImage,
//   ];

//   // Getters
//   String get selectedImage =>
//       selectedIndex < imageSelectedEventList.length
//           ? imageSelectedEventList[selectedIndex]
//           : imageSelectedEventList[0];

//   // Methods
//   void changeSelectedIndex(int index) {
//     selectedIndex = index;
//     notifyListeners();
//   }

//   Future<void> chooseDate(BuildContext context) async {
//     var chooseDate = await showDatePicker(
//       context: context,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(Duration(days: 365)),
//       initialDate: DateTime.now(),
//     );
//     if (chooseDate != null) {
//       selectedDate = chooseDate;
//       notifyListeners();
//     }
//   }

//   Future<void> chooseTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: selectedTime ?? TimeOfDay.now(),
//     );
//     if (picked != null) {
//       selectedTime = picked;
//       formatTime = picked.format(context);
//       notifyListeners();
//     }
//   }

//   String getFormattedDate(BuildContext context) {
//     if (selectedDate == null) {
//       return AppLocalizations.of(context)!.choose_date;
//     }
//     return DateFormat("dd/MM/yyyy").format(selectedDate!);
//   }

//   String getFormattedTime(BuildContext context) {
//     if (selectedTime == null) {
//       return AppLocalizations.of(context)!.choose_time;
//     }
//     return selectedTime!.format(context);
//   }
// //  7. تحديث دالة إضافة الحدث لتستخدم EventListProvider
// //  بدلاً من EventRepository مباشرة  
// Future<void> updateEvent(
//   BuildContext context,
//   EventListProvider eventListProvider,

//   UserProvider userProvider,
// ) async {
//   // ✅ 1. التحقق من صحة النموذج
//   if (formKey.currentState?.validate() != true) {
//     return;
//   }

//   // ✅ 2. التحقق من التاريخ
//   if (selectedDate == null) {
//     ToastUtils.showToast(
//       message: AppLocalizations.of(context)!.choose_date,
//       backgroundColor: Colors.red,
//     );
//     return;
//   }

//   // ✅ 3. التحقق من الوقت
//   if (selectedTime == null || formatTime == null) {
//     ToastUtils.showToast(
//       message: AppLocalizations.of(context)!.choose_time,
//       backgroundColor: Colors.red,
//     );
//     return;
//   }

//   // ✅ 4. التحقق من قائمة الأحداث
//   if (eventListProvider.eventsDataList.isEmpty) {
//     ToastUtils.showToast(
//       message: "Error: Event categories not loaded",
//       backgroundColor: Colors.red,
//     );
//     return;
//   }

//   // ✅ 5. التحقق من المستخدم
//   String? userId = userProvider.user?.id;
//   if (userId == null) {
//     ToastUtils.showToast(
//       message: "Please login first",
//       backgroundColor: Colors.red,
//     );
//     return;
//   }

//   // ✅ 6. بناء الحدث
//   // نستخدم selectedIndex + 1 لأننا استثنينا "All" من القائمة
//   int actualIndex = selectedIndex + 1;

//   Event event = Event(
//     category: eventListProvider.eventsDataList[actualIndex].categoryKey,
//     image: selectedImage, // ✅ استخدم الـ Getter
//     description: descriptionController.text,
//     title: titleController.text,
//     date: selectedDate!,
//     time: formatTime!,
//     userId: userId,
//     latitude: eventLocation?.latitude ?? 0.0,
//     longitude: eventLocation?.longitude ?? 0.0,
//   );

//   // ✅ 7. إضافة الحدث عبر EventListProvider (بدلاً من EventRepository)
//   bool success = await eventListProvider.addEvent(event, userId);

//   if (!context.mounted) return;

//   // ✅ 8. عرض النتيجة
//   if (success) {
//     ToastUtils.showToast(
//       message: AppLocalizations.of(context)!.event_added_successfully,
//       backgroundColor: Colors.green,
//     );
    
//     // ✅ 9. تنظيف البيانات
//     clearData();
    
//     // ✅ 10. العودة للصفحة السابقة
//     Navigator.pop(context);
//   } else {
//     ToastUtils.showToast(
//       message: "Error adding event",
//       backgroundColor: Colors.red,
//     );
//   }
// }
//   void clearData() {
//     selectedIndex = 0;
//     selectedDate = null;
//     selectedTime = null;
//     formatTime = null;
//     titleController.clear();
//     descriptionController.clear();
//     eventLocation = null;
//     markers.clear();
//     mapController = null;
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     titleController.dispose();
//     descriptionController.dispose();
//     mapController?.dispose();
//     super.dispose();
//   }

//   CameraPosition cameraPosition = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );

//   Future<bool> _getLocationPermission() async {
//     PermissionStatus permissionStatus;
//     permissionStatus = await location.hasPermission();

//     if (permissionStatus == PermissionStatus.denied) {
//       permissionStatus = await location.requestPermission();
//     }
//     return permissionStatus == PermissionStatus.granted;
//   }

//   Future<void> getLocation() async {
//     bool permissionGranted = await _getLocationPermission();
//     if (!permissionGranted) {
//       return;
//     }
//     bool serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) {
//         return;
//       }
//     }

//     LocationData locationData = await location.getLocation();
//     updateLocation(locationData);
//     notifyListeners();
//   }

//   void updateLocation(LocationData locationData) {
//     cameraPosition = CameraPosition(
//       target: LatLng(locationData.latitude!, locationData.longitude!),
//       zoom: 14.4746,
//     );
//     markers.clear();
//     markers.add(
//       Marker(
//         markerId: MarkerId('current_location'),
//         position: LatLng(locationData.latitude!, locationData.longitude!),
//         infoWindow: InfoWindow(title: 'Current Location'),
//       ),
//     );

//     mapController?.animateCamera(
//       CameraUpdate.newCameraPosition(cameraPosition),
//     );

//     notifyListeners();
//   }

//   void setEventLocation(LatLng latLng) {
//     eventLocation = latLng;
//     markers.add(
//       Marker(
//         markerId: MarkerId('event_location'),
//         position: latLng,
//         infoWindow: InfoWindow(title: 'Event Location'),
//       ),
//     );
//     notifyListeners();
//   }
// }



