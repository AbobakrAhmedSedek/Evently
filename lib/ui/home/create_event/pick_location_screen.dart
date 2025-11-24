import 'package:evently/providers/add_event_provider.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addEventProvider = Provider.of<AddEventProvider>(
        context,
        listen: false,
      );
      addEventProvider.getLocation();
    });
  }

  Widget build(BuildContext context) {
    AddEventProvider provider = Provider.of<AddEventProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: provider.cameraPosition,
              onMapCreated: (GoogleMapController controller) {
                provider.mapController = controller;
              },
              onTap: (LatLng latLng) {
                provider.setEventLocation(latLng);
                Navigator.pop(context, latLng);
              },
              mapType: MapType.normal,
              markers: provider.markers,
              zoomControlsEnabled: false,
              //  cameraTargetBounds: CameraTargetBounds.unbounded,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.center,
            color: AppColors.primaryLight,
            child: Text(
              AppLocalizations.of(context)!.tap_to_select_location,
              style: AppStyles.bold16White,
            ),
          ),
        ],
      ),
    );
  }
}
