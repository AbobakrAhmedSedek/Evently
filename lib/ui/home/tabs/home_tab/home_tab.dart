import 'package:evently/ui/home/tabs/home_tab/widgets/event_item.dart';
import 'package:evently/ui/home/tabs/home_tab/widgets/event_tab_item_widget.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../../utils/assets_manager.dart';
import 'models/event_data_model.dart'; // ✅ استدعاء الموديل

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int selectedIndex = 0;
  late List<EventData> eventsDataList;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    eventsDataList = [
      EventData(name: AppLocalizations.of(context)!.all, icon: Bootstrap.house),
      EventData(
        name: AppLocalizations.of(context)!.sport,
        icon: FontAwesome.futbol_solid,
      ),
      EventData(
        name: AppLocalizations.of(context)!.birthday,
        icon: Iconsax.cake_bold,
      ),
      EventData(
        name: AppLocalizations.of(context)!.meeting,
        icon: EvaIcons.people,
      ),
      EventData(
        name: AppLocalizations.of(context)!.gaming,
        icon: Bootstrap.controller,
      ),
      EventData(
        name: AppLocalizations.of(context)!.workshop,
        icon: LineAwesome.toolbox_solid,
      ),
      EventData(
        name: AppLocalizations.of(context)!.book_club,
        icon: MingCute.book_2_fill,
      ),
      EventData(
        name: AppLocalizations.of(context)!.exhibition,
        icon: Clarity.picture_line,
      ),
      EventData(
        name: AppLocalizations.of(context)!.holiday,
        icon: LineAwesome.hotel_solid,
      ),
      EventData(
        name: AppLocalizations.of(context)!.eating,
        icon: IonIcons.fast_food,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

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
                Text('Abo bakr', style: AppStyles.bold24White),
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
                  length: eventsDataList.length,
                  child: TabBar(
                      
                    onTap: (index) {
                      setState(() => selectedIndex = index);
                    },
                    labelPadding: EdgeInsets.symmetric(
                      horizontal: width * 0.01,
                    ),
                    tabAlignment: TabAlignment.start,
                    indicatorColor: Colors.transparent,
                       
                    dividerColor: Colors.transparent,
                    isScrollable: true,
                    tabs:
                        eventsDataList.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final event = entry.value;
                          return EventTabItemWidget(
                            eventName: event.name,
                            iconData: event.icon,
                            isSelected: idx == selectedIndex,
                            selectedBackgroundColor: AppColors.whiteColor,
                            unselectedBackgroundColor: AppColors.transparentColor,
                            selectedIconColor:AppColors.primaryLight,
                            unselectedIconColor: AppColors.whiteColor,
                            selectedTextStyle: AppStyles.bold16Primary,
                            unselectedTextStyle:AppStyles.bold16White ,
                            borderColor: AppColors.whiteColor ,
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return const EventItem();
              },
              itemCount: 5,
            ),
          ),
        ],
      ),
    );
  }
}
