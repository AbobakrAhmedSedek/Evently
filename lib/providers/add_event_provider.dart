import 'package:evently/model/event.dart';
import 'package:evently/providers/event_list_provider.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:evently/utils/firebase_utils.dart';
import 'package:evently/utils/toast_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> updateEvent(
    BuildContext context,
    EventListProvider eventListProvider,
    UserProvider userProvider,
  ) async {
    if (formKey.currentState?.validate() != true) {
      return;
    }

    // التحقق من التاريخ
    if (selectedDate == null) {
      ToastUtils.showToast(
        message: AppLocalizations.of(context)!.choose_date,
        backgroundColor: Colors.red,
      );
      return;
    }

    // التحقق من الوقت
    if (selectedTime == null || formatTime == null) {
      ToastUtils.showToast(
        message: AppLocalizations.of(context)!.choose_time,
        backgroundColor: Colors.red,
      );
      return;
    }

    // التحقق من قائمة الأحداث
    if (eventListProvider.eventsDataList.isEmpty) {
      ToastUtils.showToast(
        message: "Error: Event categories not loaded",
        backgroundColor: Colors.red,
      );
      return;
    }

    // التحقق من المستخدم
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ToastUtils.showToast(
        message: "Please login first",
        backgroundColor: Colors.red,
      );
      return;
    }

    // نستخدم selectedIndex + 1 لأننا استثنينا "All" من القائمة
    int actualIndex = selectedIndex + 1;

    Event event = Event(
      category: eventListProvider.eventsDataList[actualIndex].categoryKey,
      eventName: eventListProvider.eventsDataList[actualIndex].name,
      image: imageSelectedEventList[selectedIndex],
      description: descriptionController.text,
      title: titleController.text,
      date: selectedDate!,
      time: formatTime!,
      userId: userId,
      latitude: eventLocation?.latitude ?? 0.0,
      longitude: eventLocation?.longitude ?? 0.0,
    );

    try {
      await FirebaseUtils.addEvent(event, userProvider.user!.id);
      if (context.mounted) {
        ToastUtils.showToast(
          message: AppLocalizations.of(context)!.event_added_successfully,
          backgroundColor: Colors.green,
        );
        eventListProvider.getAllEvents(userProvider.user!.id);
        eventListProvider.changeSelectedIndex(0);
        clearData();
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showToast(
          message: "Error adding event: $e",
          backgroundColor: Colors.red,
        );
      }
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

    LocationData locationData = await location.getLocation();
    updateLocation(locationData);
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
    markers.add(
      Marker(
        markerId: MarkerId('event_location'),
        position: latLng,
        infoWindow: InfoWindow(title: 'Event Location'),
      ),
    );
    notifyListeners();
  }
}
