import 'package:evently/model/event.dart';
import 'package:evently/providers/maps_tab_provider.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class EventCardItem extends StatefulWidget {
  final Event event;
  const EventCardItem({super.key, required this.event});

  @override
  State<EventCardItem> createState() => _EventCardItemState();
}

class _EventCardItemState extends State<EventCardItem> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<MapsTabProvider>(context, listen: false);
      if (widget.event.latitude != null && widget.event.longitude != null) {
        provider.convertLatlang(
          LatLng(widget.event.latitude!, widget.event.longitude!),
        );
      }
    });
  }


@override
Widget build(BuildContext context) {
  MapsTabProvider provider = Provider.of<MapsTabProvider>(context);

  return Container(
    width: MediaQuery.of(context).size.width, // ← أضف عرض محدد
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.primaryLight),
      color: AppColors.whiteBgColor.withOpacity(0.7),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        AspectRatio(
          aspectRatio: 138 / 78,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(widget.event.image, fit: BoxFit.cover),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                widget.event.description.split("\n").first,
                style: AppStyles.bold16Primary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Image.asset(
                    AssetsManager.iconMap,
                    width: 20,
                    height: 20,
                    color: AppColors.blackColor,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${provider.cityName}, ${provider.countryName}',
                      style: AppStyles.bold14Black,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}