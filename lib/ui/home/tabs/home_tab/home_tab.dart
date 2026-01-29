import 'package:evently/providers/event_list_provider.dart';
import 'package:evently/providers/maps_tab_provider.dart';
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
  late Future<void> _initFuture;
  bool _isLoadingLocation = true; // ← لتتبع حالة الموقع

  @override
  void initState() {
    super.initState();
  
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

    // ✅ تحميل البيانات الأساسية
    eventListProvider.getEventsDataList(context);

    if (userProvider.user != null && eventListProvider.eventsList.isEmpty) {
      await eventListProvider.getAllEvents(userProvider.user!.id);
    }

    // ✅ تحميل الموقع في الخلفية
    _loadLocationInBackground(mapsTabProvider);
  }

  // ✅ دالة لتحميل الموقع في الخلفية
  void _loadLocationInBackground(MapsTabProvider mapsTabProvider) async {
    try {
      // استخدم الاسم الصحيح للدالة
      await mapsTabProvider.getCurrentLocation(); 
      
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var eventListProvider = Provider.of<EventListProvider>(context);
    var userProvider = Provider.of<UserProvider>(context);
    var mapsTabProvider = Provider.of<MapsTabProvider>(context);

    if (userProvider.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

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
                    // ✅ عرض الموقع مع حالة التحميل
                    Row(
                      children: [
                        SizedBox(width: width * 0.04),
                        Image.asset(
                          AssetsManager.iconMap,
                          width: 26,
                          height: 28,
                        ),
                        SizedBox(width: width * 0.02),
                        _isLoadingLocation
                            ? Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Text(
                                    "جاري تحميل الموقع...",
                                    style: AppStyles.medium14White,
                                  ),
                                ],
                              )
                            : Text(
                                "${mapsTabProvider.userCityName ?? ''} , ${mapsTabProvider.userCountryName ?? ''}",
                                style: AppStyles.medium14White,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
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
                        tabs: eventListProvider.eventsDataList
                            .asMap()
                            .entries
                            .map((entry) {
                          final idx = entry.key;
                          final event = entry.value;
                          return EventTabItemWidget(
                            eventName: event.name,
                            iconData: event.icon,
                            isSelected: idx == eventListProvider.selectedIndex,
                            selectedBackgroundColor: AppColors.whiteColor,
                            unselectedBackgroundColor: AppColors.transparentColor,
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
                child: eventListProvider.eventsFiltered.isEmpty
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