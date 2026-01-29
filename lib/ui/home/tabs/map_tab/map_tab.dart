
// ═══════════════════════════════════════════════════════════
// 📄 map_tab.dart
// ═══════════════════════════════════════════════════════════

import 'package:evently/domain/model/event.dart';
import 'package:evently/providers/maps_tab_provider.dart';
import 'package:evently/ui/home/tabs/map_tab/widgets/event_card_item.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late MapsTabProvider provider;
  @override
  void initState() {
    super.initState();
    _setupRealtimeListener();
    _initializeMapLocation(); // ✅✅✅ إضافة: جلب الموقع تلقائيًا
  }

  void _setupRealtimeListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MapsTabProvider provider = Provider.of<MapsTabProvider>(
        context,
        listen: false,
      );

      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        provider.trackEventUpdates(userId);
      }
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = Provider.of<MapsTabProvider>(context, listen: false);
  }


  // ✅✅✅ إضافة جديدة: دالة لجلب الموقع عند تحميل الـ Tab
  void _initializeMapLocation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MapsTabProvider provider = Provider.of<MapsTabProvider>(
        context,
        listen: false,
      );

      // استخدام نفس دالة الـ FAB لجلب الموقع وتحديث الخريطة
      provider.floatingActionButtonLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // MapsTabProvider provider = Provider.of<MapsTabProvider>(context);
    var height = MediaQuery.of(context).size.height;

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
              height: height * 0.15,
              child: StreamBuilder<List<Event>>(
                stream: provider.eventsStream,
                initialData: provider.eventsFiltered,
                builder: (context, snapshot) {
                  // حالة التحميل
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  }

                  // حالة الخطأ
                  if (snapshot.hasError) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  // الحصول على البيانات
                  final events = snapshot.data ?? [];

                  // حالة عدم وجود أحداث
                  if (events.isEmpty) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_busy, color: Colors.grey[400]),
                            const SizedBox(width: 8),
                            const Text(
                              'No events found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // عرض قائمة الأحداث
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Event event = events[index];
                          provider.convertLatlangAndSetLocation(
                            LatLng(event.latitude!, event.longitude!),
                            event.title,
                          );
                        },
                        child: EventCardItem(event: events[index]),
                      );
                    },
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
            provider.floatingActionButtonLocation();
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
  @override
  void dispose() {
  provider.cancelSubscription(); // ✅
  print("🟣 MapTab dispose() called!"); 
    super.dispose();
  }
}
