import 'package:evently/providers/event_list_provider.dart';
import 'package:evently/providers/maps_tab_provider.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:evently/ui/home/tabs/home_tab/widgets/event_item.dart';
import 'package:evently/ui/home/tabs/home_tab/widgets/event_tab_item_widget.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../utils/app_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    // ✅ انتظار اكتمال بناء الـ widget قبل الوصول للـ context
    _initFuture = Future(() async {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      await _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final eventListProvider = context.read<EventListProvider>();
    final userProvider = context.read<UserProvider>();
    final mapsTabProvider = context.read<MapsTabProvider>();

    // ✅ getEventsDataList متزامنة (void) - تعمل فوراً بدون await
    eventListProvider.getEventsDataList(context);

    // ✅ getAllEvents غير متزامنة (Future<void>) - تحتاج await
    if (userProvider.user != null && eventListProvider.eventsList.isEmpty) {
      await eventListProvider.getAllEvents(userProvider.user!.id);
    }

    // ✅ عمليات الموقع - async تحتاج await
    final locationData = await mapsTabProvider.location.getLocation();
    mapsTabProvider.convertLatlang(
      LatLng(locationData.latitude!, locationData.longitude!),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var eventListProvider = Provider.of<EventListProvider>(context);
    var userProvider = Provider.of<UserProvider>(context);
    var mapsTabProvider = Provider.of<MapsTabProvider>(context);

    // ✅ لو المستخدم لم يُحمّل بعد، نعرض دائرة تحميل
    if (userProvider.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        // ✅ حالة التحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ حالة الخطأ
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: AppStyles.bold20Primary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // ✅ البيانات جاهزة - عرض الواجهة الرئيسية
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.welcome_back,
                      style: AppStyles.regular14White,
                    ),
                    Text(userProvider.user!.name, style: AppStyles.bold24White),
                  ],
                ),
                const Spacer(),
                Image.asset(AssetsManager.iconTheme, width: 26, height: 26),
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("EN", style: AppStyles.bold20Primary),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // ✅ Container الخاص بالموقع والـ Tabs
              Container(
                height: height * .136,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  border: const Border(bottom: BorderSide(color: Colors.white)),
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  children: [
                    SizedBox(height: height * 0.01),
                    // ✅ عرض الموقع
                    Row(
                      children: [
                        SizedBox(width: width * 0.04),
                        Image.asset(
                          AssetsManager.iconMap,
                          width: 26,
                          height: 28,
                        ),
                        SizedBox(width: width * 0.02),
                        Text(
                          "${mapsTabProvider.cityName} , ${mapsTabProvider.countryName}",
                          style: AppStyles.medium14White,
                          maxLines: 1, // ← حد أقصى سطر واحد
                          overflow:
                              TextOverflow
                                  .ellipsis, // ← نقاط في النهاية إذا طالت النص
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    // ✅ TabBar للفئات
                    DefaultTabController(
                      length: eventListProvider.eventsDataList.length,
                      child: TabBar(
                        onTap: (index) {
                          setState(() {
                            eventListProvider.changeSelectedIndex(index);
                          });
                        },
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: width * 0.01,
                        ),
                        tabAlignment: TabAlignment.start,
                        indicatorColor: Colors.transparent,
                        dividerColor: Colors.transparent,
                        isScrollable: true,
                        tabs:
                            eventListProvider.eventsDataList
                                .asMap()
                                .entries
                                .map((entry) {
                                  final idx = entry.key;
                                  final event = entry.value;
                                  return EventTabItemWidget(
                                    eventName: event.name,
                                    iconData: event.icon,
                                    isSelected:
                                        idx == eventListProvider.selectedIndex,
                                    selectedBackgroundColor:
                                        AppColors.whiteColor,
                                    unselectedBackgroundColor:
                                        AppColors.transparentColor,
                                    selectedIconColor: AppColors.primaryLight,
                                    unselectedIconColor: AppColors.whiteColor,
                                    selectedTextStyle: AppStyles.bold16Primary,
                                    unselectedTextStyle: AppStyles.bold16White,
                                    borderColor: AppColors.whiteColor,
                                  );
                                })
                                .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              // ✅ قائمة الأحداث
              Expanded(
                child:
                    eventListProvider.eventsFiltered.isEmpty
                        ? Center(
                          child: Text(
                            AppLocalizations.of(context)!.no_events_found,
                            style: AppStyles.bold20Primary,
                          ),
                        )
                        : ListView.builder(
                          itemBuilder: (context, index) {
                            return EventItem(
                              event: eventListProvider.eventsFiltered[index],
                            );
                          },
                          itemCount: eventListProvider.eventsFiltered.length,
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}
// ----------------------------------------------------------------------
// import 'package:evently/providers/event_list_provider.dart';
// import 'package:evently/providers/maps_tab_provider.dart';
// import 'package:evently/providers/user_provider.dart';
// import 'package:evently/ui/home/tabs/home_tab/widgets/event_item.dart';
// import 'package:evently/ui/home/tabs/home_tab/widgets/event_tab_item_widget.dart';
// import 'package:evently/utils/app_colors.dart';
// import 'package:evently/utils/assets_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:location/location.dart';
// import 'package:provider/provider.dart';
// import '../../../../utils/app_styles.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class HomeTab extends StatefulWidget {
//   const HomeTab({super.key});

//   @override
//   State<HomeTab> createState() => _HomeTabState();
// }

// class _HomeTabState extends State<HomeTab> {
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Future.microtask(() async {
//         var eventListProvider = Provider.of<EventListProvider>(
//           context,
//           listen: false,
//         );
//         var userProvider = Provider.of<UserProvider>(context, listen: false);

//         // ✅ تحميل قائمة الأحداث العامة
//         eventListProvider.getEventsDataList(context);

//         // ✅ تحميل الأحداث الخاصة بالمستخدم بعد التأكد أنه مسجل دخول
//         if (userProvider.user != null && eventListProvider.eventsList.isEmpty) {
//           eventListProvider.getAllEvents(userProvider.user!.id);
//         }
//         MapsTabProvider provider = Provider.of<MapsTabProvider>(
//           context,
//           listen: false,
//         );
//         LocationData locationData = await provider.location.getLocation();
//         provider.convertLatlang(locationData);
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;
//     var eventListProvider = Provider.of<EventListProvider>(context);
//     var userProvider = Provider.of<UserProvider>(context);
//     MapsTabProvider provider = Provider.of<MapsTabProvider>(context);

//     // ✅ لو المستخدم لم يُحمّل بعد، نعرض دائرة تحميل بدلاً من الكراش
//     if (userProvider.user == null) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).primaryColor,
//         title: Row(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   AppLocalizations.of(context)!.welcome_back,
//                   style: AppStyles.regular14White,
//                 ),
//                 Text(userProvider.user!.name, style: AppStyles.bold24White),
//               ],
//             ),
//             const Spacer(),
//             Image.asset(AssetsManager.iconTheme, width: 26, height: 26),
//             Container(
//               margin: const EdgeInsets.all(10),
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text("EN", style: AppStyles.bold20Primary),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Container(
//             height: height * .136,
//             decoration: BoxDecoration(
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(25),
//                 bottomRight: Radius.circular(25),
//               ),
//               border: const Border(bottom: BorderSide(color: Colors.white)),
//               color: Theme.of(context).primaryColor,
//             ),
//             child: Column(
//               children: [
//                 SizedBox(height: height * 0.01),
//                 Row(
//                   children: [
//                     SizedBox(width: width * 0.04),
//                     Image.asset(AssetsManager.iconMap, width: 26, height: 28),
//                     SizedBox(width: width * 0.02),
//                     Text(
//                       "${provider.cityName} , ${provider.countryName}",
//                       style: AppStyles.medium14White,
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: height * 0.02),

//                 /// ✅ TabBar باستخدام الموديل
//                 DefaultTabController(
//                   length: eventListProvider.eventsDataList.length,
//                   child: TabBar(
//                     onTap: (index) {
//                       setState(
//                         () => eventListProvider.changeSelectedIndex(index),
//                       );
//                     },
//                     labelPadding: EdgeInsets.symmetric(
//                       horizontal: width * 0.01,
//                     ),
//                     tabAlignment: TabAlignment.start,
//                     indicatorColor: Colors.transparent,

//                     dividerColor: Colors.transparent,
//                     isScrollable: true,
//                     tabs:
//                         eventListProvider.eventsDataList.asMap().entries.map((
//                           entry,
//                         ) {
//                           final idx = entry.key;
//                           final event = entry.value;
//                           return EventTabItemWidget(
//                             eventName: event.name,
//                             iconData: event.icon,
//                             isSelected: idx == eventListProvider.selectedIndex,
//                             selectedBackgroundColor: AppColors.whiteColor,
//                             unselectedBackgroundColor:
//                                 AppColors.transparentColor,
//                             selectedIconColor: AppColors.primaryLight,
//                             unselectedIconColor: AppColors.whiteColor,
//                             selectedTextStyle: AppStyles.bold16Primary,
//                             unselectedTextStyle: AppStyles.bold16White,
//                             borderColor: AppColors.whiteColor,
//                           );
//                         }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child:
//                 eventListProvider.eventsFiltered.isEmpty
//                     ? Center(
//                       child: Text(
//                         AppLocalizations.of(context)!.no_events_found,
//                         style: AppStyles.bold20Primary,
//                       ),
//                     )
//                     : ListView.builder(
//                       itemBuilder: (BuildContext context, int index) {
//                         return EventItem(
//                           event: eventListProvider.eventsFiltered[index],
//                         );
//                       },
//                       itemCount: eventListProvider.eventsFiltered.length,
//                     ),
//           ),
//         ],
//       ),
//     );
//   }
// }
