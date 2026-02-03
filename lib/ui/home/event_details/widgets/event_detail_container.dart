import 'package:evently/providers/event_details_provider.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class EventDetailContainer extends StatelessWidget {
  final Icon? icon;
  final String assetsManager;
  final DateTime? selectedDate;
  final String? selectedTime;
  final String? city;
  final String? country;
  final LatLng? latLng;

  const EventDetailContainer({
    super.key,
    this.icon,
    required this.assetsManager,
    this.selectedDate,
    this.selectedTime,
    this.city,
    this.country,
    this.latLng,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: SizedBox(
              height: 25,
              width: 25,
              child: Image.asset(assetsManager, color: AppColors.whiteColor),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectedDate != null)
                Text(
                  Provider.of<EventDetailsProvider>(
                    context,
                  ).formatDate(selectedDate!),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 20),
                ),
              if (selectedTime != null)
                Text(
                  Provider.of<EventDetailsProvider>(
                    context,
                  ).formatTime(selectedTime!),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 20),
                ),
              if (city != null && country != null)
                Text(
                  '$city, $country',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 20),
                ),
              
            ],
          ),
          Spacer(),
          icon ?? Container(),
          SizedBox(width: width * 0.02),
        ],
      ),
    );
  }
}
