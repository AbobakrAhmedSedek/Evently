
import 'package:evently/providers/add_event_provider.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PickLocationScreen extends StatefulWidget {
  static const routeName = '/pick-location';
  const PickLocationScreen({super.key});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  // متغير لتتبع إذا تم اختيار موقع
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addEventProvider = Provider.of<AddEventProvider>(
        context,
        listen: false,
      );
      addEventProvider.getLocation();
      
      // إذا كان هناك موقع محدد مسبقاً
      if (addEventProvider.eventLocation != null) {
        selectedLocation = addEventProvider.eventLocation;
      }
    });
  }

  // دالة للتحقق من صلاحية الموقع
  bool _isValidLocation(LatLng? location) {
    return location != null && 
           location.latitude != 0.0 && 
           location.longitude != 0.0;
  }

  // دالة لعرض رسالة تحذيرية عند محاولة الخروج بدون اختيار
  Future<bool> _handleBackNavigation() async {
    if (_isValidLocation(selectedLocation)) {
      return true; // السماح بالخروج
    }

  // ✅ عرض showToast تحذيري
  ToastUtils.showToast(
    message: AppLocalizations.of(context)!.please_select_location_first,
    backgroundColor: Colors.red,
  );

    return false; // منع الخروج
  }

  @override
  Widget build(BuildContext context) {
    AddEventProvider provider = Provider.of<AddEventProvider>(context);
    
    return PopScope(
      canPop: false, // منع الرجوع التلقائي
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          bool canPop = await _handleBackNavigation();
          if (canPop && context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        
        appBar: AppBar(
          centerTitle: true,
          leading: _isValidLocation(selectedLocation) 
      ? IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryLight),
          onPressed: () async {
            bool canPop = await _handleBackNavigation();
            if (canPop && context.mounted) {
              Navigator.pop(context);
            }
          },
        )
      : SizedBox.shrink(),
          title: Text(
            AppLocalizations.of(context)!.select_location ,
            style: AppStyles.medium20Primary,
          ),
        ),
        body: Column(
          children: [
            // الخريطة
            Expanded(
              child: GoogleMap(
                initialCameraPosition: provider.cameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  provider.mapController = controller;
                },
                onTap: (LatLng latLng) {
                  setState(() {
                    selectedLocation = latLng;
                  });
                  provider.setEventLocation(latLng);
                  Navigator.pop(context, latLng);
                },
                mapType: MapType.normal,
                markers: provider.markers,
                zoomControlsEnabled: false,
              ),
            ),

            // معلومات الموقع المحدد
            // if (_isValidLocation(selectedLocation))
            // رسالة التوجيه
            Container(
              padding: EdgeInsets.all(12),
              color: _isValidLocation(selectedLocation) 
                  ? Colors.green 
                  : AppColors.primaryLight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isValidLocation(selectedLocation) 
                        ? Icons.check_circle_outline 
                        : Icons.touch_app,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isValidLocation(selectedLocation)
                          ? AppLocalizations.of(context)!.location_selected_tap_confirm 
                          : AppLocalizations.of(context)!.tap_to_select_location ,
                      style: AppStyles.medium16White,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                ],
              ),
            ),

          
          ],
        ),
      ),
    );
  }
}


// --------------------------------------------------------------------------------

// import 'package:evently/providers/add_event_provider.dart';
// import 'package:evently/utils/app_colors.dart';
// import 'package:evently/utils/app_styles.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class PickLocationScreen extends StatefulWidget {
//   static const routeName = '/pick-location';
//   const PickLocationScreen({super.key});

//   @override
//   State<PickLocationScreen> createState() => _PickLocationScreenState();
// }

// class _PickLocationScreenState extends State<PickLocationScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final addEventProvider = Provider.of<AddEventProvider>(
//         context,
//         listen: false,
//       );
//       addEventProvider.getLocation();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     AddEventProvider provider = Provider.of<AddEventProvider>(context);
//     return Scaffold(
//       body: Column(
//         children: [
//           Expanded(
//             child: GoogleMap(
//               initialCameraPosition: provider.cameraPosition,
//               onMapCreated: (GoogleMapController controller) {
//                 provider.mapController = controller;
//               },
//               onTap: (LatLng latLng) {
//                 provider.setEventLocation(latLng);
//                 Navigator.pop(context, latLng);
//               },
//               mapType: MapType.normal,
//               markers: provider.markers,
//               zoomControlsEnabled: false,
//               //  cameraTargetBounds: CameraTargetBounds.unbounded,
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             alignment: Alignment.center,
//             color: AppColors.primaryLight,
//             child: Text(
//               AppLocalizations.of(context)!.tap_to_select_location,
//               style: AppStyles.bold16White,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
