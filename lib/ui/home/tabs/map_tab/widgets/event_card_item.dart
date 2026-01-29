  
  // ═══════════════════════════════════════════════════════════
// 📄 event_card_item.dart
// ═══════════════════════════════════════════════════════════

import 'package:evently/domain/model/event.dart';
import 'package:evently/providers/maps_tab_provider.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅✅✅ تغيير: من StatefulWidget إلى StatelessWidget
class EventCardItem extends StatelessWidget {
  final Event event;
  const EventCardItem({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // ✅✅✅ تغيير: استخدام listen: false (لا نحتاج إعادة بناء)
    final provider = Provider.of<MapsTabProvider>(context, listen: false);

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8),
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
              child: Image.asset(event.image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  event.description.split("\n").first,
                  style: AppStyles.bold16Primary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Image.asset(
                      AssetsManager.iconMap,
                      width: 20,
                      height: 20,
                      color: AppColors.blackColor,
                    ),
                    const SizedBox(width: 4),
                    // ✅✅✅ التغيير الرئيسي: استخدام FutureBuilder
                    Expanded(
                      child: FutureBuilder<Map<String, String>>(
                        // استدعاء الدالة الجديدة من Provider
                        future: provider.getEventLocation(event),
                        builder: (context, snapshot) {
                          // حالة التحميل
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }

                          // حالة الخطأ أو عدم وجود بيانات
                          if (snapshot.hasError || !snapshot.hasData) {
                            return Text(
                              'Error, Error',
                              style: AppStyles.bold14Black,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          }

                          // عرض البيانات
                          final location = snapshot.data!;
                          return Text(
                            '${location['city']}, ${location['country']}',
                            style: AppStyles.bold14Black,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
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

// ===============================================================

// import 'package:evently/domain/model/event.dart';
// import 'package:evently/providers/maps_tab_provider.dart';
// import 'package:evently/utils/app_colors.dart';
// import 'package:evently/utils/app_styles.dart';
// import 'package:evently/utils/assets_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class EventCardItem extends StatefulWidget {
//   final Event event;
//   const EventCardItem({super.key, required this.event});

//   @override
//   State<EventCardItem> createState() => _EventCardItemState();
// }

// class _EventCardItemState extends State<EventCardItem> {
//   @override
  
//   @override
//   Widget build(BuildContext context) {
//     MapsTabProvider provider = Provider.of<MapsTabProvider>(context);

//     return Container(
//       width: MediaQuery.of(context).size.width, // ← أضف عرض محدد
//       padding: EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColors.primaryLight),
//         color: AppColors.whiteBgColor.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           AspectRatio(
//             aspectRatio: 138 / 78,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.asset(widget.event.image, fit: BoxFit.cover),
//             ),
//           ),
//           SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.event.description.split("\n").first,
//                   style: AppStyles.bold16Primary,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Image.asset(
//                       AssetsManager.iconMap,
//                       width: 20,
//                       height: 20,
//                       color: AppColors.blackColor,
//                     ),
//                     SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         '${provider.selectedEventCityName}, ${provider.selectedEventCountryName}',
//                         style: AppStyles.bold14Black,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
