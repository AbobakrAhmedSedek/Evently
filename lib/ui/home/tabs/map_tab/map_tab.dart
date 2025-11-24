import 'package:evently/model/event.dart';
import 'package:evently/providers/maps_tab_provider.dart';
import 'package:evently/ui/home/tabs/map_tab/widgets/event_card_item.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MapsTabProvider provider = Provider.of<MapsTabProvider>(
        context,
        listen: false,
      );

      // جلب User ID من Firebase Auth
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      provider.getAllEvents(userId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    MapsTabProvider provider = Provider.of<MapsTabProvider>(context);
    var height = MediaQuery.of(context).size.height;
    // var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          // الخريطة
          GoogleMap(
            initialCameraPosition: provider.cameraPosition,
            onMapCreated: (GoogleMapController controller) {
              provider.mapController = controller;
            },
            mapType: MapType.normal,
            markers: provider.markers,
            zoomControlsEnabled: false,
          ),

          // الـ ListView أسفل الشاشة بارتفاع ثابت
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: SizedBox(
              height: height * 0.15, // ضع أي ارتفاع يناسبك
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                scrollDirection: Axis.horizontal,
                itemCount: provider.eventsFiltered.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Event event = provider.eventsFiltered[index];

                      provider.updateLocation(
                        LocationData.fromMap({
                          'latitude': event.latitude,
                          'longitude': event.longitude,
                        }),
                        event.title,
                      );
                    },
                    child: EventCardItem(event: provider.eventsFiltered[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: FloatingActionButton(
          onPressed: () {
            provider.getLocation();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: AppColors.whiteColor,
          child: const Icon(Icons.gps_fixed),
        ),
      ),
    );
  }
}
