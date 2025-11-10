import 'package:evently/providers/event_list_provider.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:evently/ui/home/tabs/home_tab/widgets/event_item.dart';
import 'package:evently/ui/home/tabs/home_tab/widgets/event_tab_item_widget.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/app_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var eventListProvider =
          Provider.of<EventListProvider>(context, listen: false);
      var userProvider = Provider.of<UserProvider>(context, listen: false);

      // ✅ تحميل قائمة الأحداث العامة
      eventListProvider.getEventsDataList(context);

      // ✅ تحميل الأحداث الخاصة بالمستخدم بعد التأكد أنه مسجل دخول
      if (userProvider.user != null &&
          eventListProvider.eventsList.isEmpty) {
        eventListProvider.getAllEvents(userProvider.user!.id);
      }
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var eventListProvider = Provider.of<EventListProvider>(context);
    var userProvider = Provider.of<UserProvider>(context);

    // ✅ لو المستخدم لم يُحمّل بعد، نعرض دائرة تحميل بدلاً من الكراش
    if (userProvider.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar:  AppBar(
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
                Text(
                  userProvider.user! .name ,
                  style: AppStyles.bold24White,
                ),
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
      body:  Column(
        children: [
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
                Row(
                  children: [
                    SizedBox(width: width * 0.04),
                    Image.asset(AssetsManager.iconMap, width: 26, height: 28),
                    SizedBox(width: width * 0.02),
                    Text("Cairo , Egypt", style: AppStyles.medium14White),
                  ],
                ),
                SizedBox(height: height * 0.02),

                /// ✅ TabBar باستخدام الموديل
                DefaultTabController(
                  length: eventListProvider.eventsDataList.length,
                  child: TabBar(
                    onTap: (index) {
                      setState(
                        () => eventListProvider.changeSelectedIndex(index),
                      );
                    },
                    labelPadding: EdgeInsets.symmetric(
                      horizontal: width * 0.01,
                    ),
                    tabAlignment: TabAlignment.start,
                    indicatorColor: Colors.transparent,

                    dividerColor: Colors.transparent,
                    isScrollable: true,
                    tabs:
                        eventListProvider.eventsDataList.asMap().entries.map((
                          entry,
                        ) {
                          final idx = entry.key;
                          final event = entry.value;
                          return EventTabItemWidget(
                            eventName: event.name,
                            iconData: event.icon,
                            isSelected: idx == eventListProvider.selectedIndex,
                            selectedBackgroundColor: AppColors.whiteColor,
                            unselectedBackgroundColor:
                                AppColors.transparentColor,
                            selectedIconColor: AppColors.primaryLight,
                            unselectedIconColor: AppColors.whiteColor,
                            selectedTextStyle: AppStyles.bold16Primary,
                            unselectedTextStyle: AppStyles.bold16White,
                            borderColor: AppColors.whiteColor,
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
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
                      itemBuilder: (BuildContext context, int index) {
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
  }
    
  }



// ----------------------------------------------------------------------
// import 'package:evently/providers/event_list_provider.dart';
// import 'package:evently/providers/user_provider.dart';
// import 'package:evently/ui/home/tabs/home_tab/widgets/event_item.dart';
// import 'package:evently/ui/home/tabs/home_tab/widgets/event_tab_item_widget.dart';
// import 'package:evently/utils/app_colors.dart';
// import 'package:evently/utils/app_styles.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:provider/provider.dart';
// import '../../../../utils/assets_manager.dart';

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
//       var eventListProvider = Provider.of<EventListProvider>(
//         context,
//         listen: false,
//       );
//       var userProvider = Provider.of<UserProvider>(context , listen: false) ;
//       eventListProvider.getEventsDataList(context);
//       if (eventListProvider.eventsList.isEmpty) {
//         eventListProvider.getAllEvents(userProvider.user!.id);
//       }
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     var eventListProvider = Provider.of<EventListProvider>(context);
//     var userProvider = Provider.of<UserProvider>(context);
//     var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;

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
//                 Text(
//                   userProvider.user! .name ,
//                   style: AppStyles.bold24White,
//                 ),
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
//                     Text("Cairo , Egypt", style: AppStyles.medium14White),
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
