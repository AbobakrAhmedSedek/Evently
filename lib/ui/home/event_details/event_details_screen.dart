import 'dart:async';

import 'package:evently/ui/home/create_event/add_event.dart';
import 'package:evently/ui/home/event_details/widgets/event_detail_container.dart';
import 'package:evently/ui/home/tabs/home_tab/cubit/events/event_action.dart';
import 'package:evently/ui/home/tabs/home_tab/cubit/events/event_cubit.dart';
import 'package:evently/ui/home/tabs/home_tab/cubit/events/event_state.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:evently/domain/model/event.dart';

class EventDetailsScreen extends StatefulWidget {
  static const routeName = '/event-details';
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late StreamSubscription<EventAction> _actionSubscription;
  late Event _event;
  @override

  void initState() {
    super.initState();
    final cubit = context.read<EventCubit>();
    _event = context.read<EventCubit>().getEventById(widget.eventId);
    debugPrint("Cubit hashCode: ${cubit.hashCode}");
    _actionSubscription = cubit.actions.listen((action) {
      debugPrint("Action received: $action");

      switch (action) {
        case const EventAction.deleteSuccess():
      Navigator.of(context).pop();
      }
    });
  }

  @override

  void dispose() {
    super.dispose();
    _actionSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, EventsState>(
      
      builder: (context, state) {
        debugPrint("BlocBuilder rebuilt");
        // final event = context.read<EventCubit>().getEventById(widget.eventId);
        debugPrint("Event is null? ${_event  == null}");
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.event_details,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  Navigator.of(
                    context,
                  ).pushNamed(AddEvent.routeName, arguments: _event);
                },
                color: Theme.of(context).iconTheme.color,
              ),

              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  // await context.read<EventCubit>().deleteEvent(event);
                  final cubit = context.read<EventCubit>();
                  await cubit.deleteEvent(_event);
                  // Navigator.pop(context);
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

                  child: Image.asset(_event.image, fit: BoxFit.cover),
                ),
                Text(_event.title, style: AppStyles.bold20Primary),
                EventDetailContainer(
                  assetsManager: AssetsManager.iconDate,
                  selectedDate: _event.date,
                  selectedTime: _event.time,
                ),
                EventDetailContainer(
                  assetsManager: AssetsManager.iconLocation,
                  icon: Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: AppColors.primaryLight,
                  ),
                  city: _event.city,
                  country: _event.country,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: AppColors.primaryLight,
                      width: 2.0,
                    ),
                  ),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.34,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_event.latitude!, _event.longitude!),
                        zoom: 14.0,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('_event!_location'),
                          position: LatLng(_event.latitude!, _event.longitude!),
                        ),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
