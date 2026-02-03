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
import 'package:geocoding/geocoding.dart' as geo;

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
  
  // ✅ متغيرات جديدة للـ City & Country
  String? eventCity;
  String? eventCountry;

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

  // ✅ دالة جديدة لتحويل LatLng لـ City & Country
  Future<void> getAddressFromLocation(LatLng latLng) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        eventCity = place.locality ?? place.subAdministrativeArea ?? 'Unknown City';
        eventCountry = place.country ?? 'Unknown Country';
        
        print('City: $eventCity, Country: $eventCountry'); // للتأكد
        notifyListeners();
      }
    } catch (e) {
      print('Error getting address: $e');
      eventCity = 'Unknown City';
      eventCountry = 'Unknown Country';
      notifyListeners();
    }
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
        message: AppLocalizations.of(context)!.please_choose_location,
        backgroundColor: Colors.red,
      );
      return;
    }

    // ✅ 5. التحقق من وجود City & Country
    if (eventCity == null || eventCountry == null) {
      ToastUtils.showToast(
        message: "Getting location details...",
        backgroundColor: Colors.orange,
      );
      
      // ✅ محاولة الحصول عليهم مرة أخرى
      if (eventLocation != null) {
        await getAddressFromLocation(eventLocation!);
      }
      
      // لو لسه null
      if (eventCity == null || eventCountry == null) {
        ToastUtils.showToast(
          message: "Could not get location details",
          backgroundColor: Colors.red,
        );
        return;
      }
    }

    // ✅ 6. التحقق من قائمة الأحداث
    if (eventListProvider.eventsDataList.isEmpty) {
      ToastUtils.showToast(
        message: "Error: Event categories not loaded",
        backgroundColor: Colors.red,
      );
      return;
    }

    // ✅ 7. التحقق من المستخدم
    String? userId = userProvider.user?.id;
    if (userId == null) {
      ToastUtils.showToast(
        message: "Please login first",
        backgroundColor: Colors.red,
      );
      return;
    }

    // ✅ 8. بناء الحدث
    int actualIndex = selectedIndex + 1;

    Event event = Event(
      category: eventListProvider.eventsDataList[actualIndex].categoryKey,
      image: selectedImage,
      description: descriptionController.text,
      title: titleController.text,
      date: selectedDate!,
      time: formatTime!,
      userId: userId,
      latitude: eventLocation!.latitude,
      longitude: eventLocation!.longitude,
      city: eventCity,        // ✅ أضف هنا
      country: eventCountry,  // ✅ أضف هنا
    );

    // ✅ 9. إضافة الحدث
    bool success = await eventListProvider.addEvent(event, userId);

    if (!context.mounted) return;

    // ✅ 10. عرض النتيجة
    if (success) {
      ToastUtils.showToast(
        message: AppLocalizations.of(context)!.event_added_successfully,
        backgroundColor: Colors.green,
      );
      
      // ✅ 11. تنظيف البيانات
      clearData();
      
      // ✅ 12. العودة للصفحة السابقة
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
    eventCity = null;      // ✅ أضف هنا
    eventCountry = null;   // ✅ أضف هنا
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

  // ✅ عدّل دالة setEventLocation
  Future<void> setEventLocation(LatLng latLng) async {
    eventLocation = latLng;
    
    // ✅ حوّل الموقع لـ City & Country
    await getAddressFromLocation(latLng);
    
    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId('event_location'),
        position: latLng,
        infoWindow: InfoWindow(
          title: 'Event Location',
          snippet: eventCity != null && eventCountry != null 
              ? '$eventCity, $eventCountry' 
              : null,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    notifyListeners();
  }
 
}
