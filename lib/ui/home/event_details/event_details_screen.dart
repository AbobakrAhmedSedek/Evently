import 'package:evently/data/repositories/event_repository.dart';
import 'package:evently/domain/model/event.dart';
import 'package:evently/ui/home/create_event/add_event.dart';
import 'package:evently/ui/home/event_details/widgets/event_detail_container.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventDetailsScreen extends StatefulWidget {
  static const routeName = '/event-details';
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.event_details,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: AppColors.primaryLight),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              Navigator.of(context).pushNamed(
                 AddEvent.routeName,
                arguments: widget.event,
              );
            
            },
            color: Theme.of(context).iconTheme.color,
          ),

          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await EventRepository().deleteEvent(
                widget.event.userId,
                widget.event.id,
              );
              Navigator.of(context).pop();
            },
            color: AppColors.redColor,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.0,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(widget.event.image, fit: BoxFit.cover),
            ),
            Text(widget.event.title, style: AppStyles.bold20Primary),
            EventDetailContainer(
              assetsManager: AssetsManager.iconDate,
              selectedDate: widget.event.date,
              selectedTime: widget.event.time,
            ),
            EventDetailContainer(
              assetsManager: AssetsManager.iconLocation,
              icon: Icon(
                Icons.arrow_forward_ios_outlined,
                color: AppColors.primaryLight,
              ),
              city: widget.event.city,
              country: widget.event.country,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: AppColors.primaryLight, width: 2.0),
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.34,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      widget.event.latitude!,
                      widget.event.longitude!,
                    ),
                    zoom: 14.0,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('event_location'),
                      position: LatLng(
                        widget.event.latitude!,
                        widget.event.longitude!,
                      ),
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
