import 'package:evently/constants/event_categories.dart';
import 'package:evently/domain/model/event.dart';
import 'package:evently/domain/model/my_user.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:evently/ui/home/tabs/home_tab/cubit/events/event_cubit.dart';
import 'package:evently/ui/home/tabs/home_tab/cubit/events/event_state.dart';
import 'package:evently/ui/home/tabs/home_tab/cubit/location/location_cubit.dart';
import 'package:evently/ui/home/tabs/home_tab/cubit/location/location_state.dart';
import 'package:evently/ui/home/tabs/home_tab/widgets/event_item_widget.dart';
import 'package:evently/ui/home/tabs/home_tab/widgets/event_tab_item_widget.dart';
import 'package:evently/ui/home/tabs/home_tab/widgets/location_item.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasLoadedEvents = false;
  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: EventCategories.categories.length,
      vsync: this,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        context.read<EventCubit>().getFilterEvents(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getLocalizedName(String categoryKey, BuildContext context) {
    switch (categoryKey) {
      case 'all':
        return AppLocalizations.of(context)!.all;
      case 'sport':
        return AppLocalizations.of(context)!.sport;
      case 'birthday':
        return AppLocalizations.of(context)!.birthday;
      case 'meeting':
        return AppLocalizations.of(context)!.meeting;
      case 'gaming':
        return AppLocalizations.of(context)!.gaming;
      case 'workshop':
        return AppLocalizations.of(context)!.workshop;
      case 'book_club':
        return AppLocalizations.of(context)!.book_club;
      case 'exhibition':
        return AppLocalizations.of(context)!.exhibition;
      case 'holiday':
        return AppLocalizations.of(context)!.holiday;
      case 'eating':
        return AppLocalizations.of(context)!.eating;

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<UserProvider, MyUser?>((p) => p.user);

    if (user != null && !_hasLoadedEvents) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _hasLoadedEvents = true;

        context.read<EventCubit>().getAllEvents(user.id);
      });
    }

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.white, width: 1.0),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
        ),
        toolbarHeight: 90,
        // automaticallyImplyLeading: false,
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
                Text(user?.name ?? " Guest ", style: AppStyles.bold24White),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),

          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, state) {
                    switch (state) {
                      case LocationInitial():
                        return const SizedBox();
                      case LocationLoading():
                        return LocationItem(
                          child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "جاري تحميل الموقع...",
                                style: AppStyles.medium14White,
                                maxLines: 1,

                                // overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      case LocationSuccess(
                        cityName: final cityName,
                        countryName: final countryName,
                      ):
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            " $cityName , $countryName ",
                            style: AppStyles.medium14White,
                            maxLines: 1,

                            // overflow: TextOverflow.ellipsis,
                          ),
                        );
                      case LocationError(message: final error):
                        return Text(
                          error,
                          style: AppStyles.medium14White,
                          maxLines: 1,

                          // overflow: TextOverflow.ellipsis,
                        );
                    }
                  },
                ),
                SizedBox(height: 15),

                BlocSelector<EventCubit, EventsState, int>(
                  selector: (state) {
                    return state.map(
                      initial: (_) => 0,
                      loading: (s) => s.selectedIndex,
                      success: (s) => s.selectedIndex,
                      error: (s) => s.selectedIndex,
                    );
                  },
                  builder: (context, selectedIndex) {
                    return TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: Colors.transparent,
                      dividerColor: Colors.transparent,
                      tabAlignment: TabAlignment.start,
                      tabs:
                          EventCategories.categories.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final event = entry.value;

                            return EventTabItemWidget(
                              eventName: _getLocalizedName(
                                event.categoryKey,
                                context,
                              ),
                              iconData: event.icon,

                              isSelected: index == selectedIndex,

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
                    );
                  },
                ),
                SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),

      body: BlocBuilder<EventCubit, EventsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox(),
            loading: (_) => const Center(child: CircularProgressIndicator()),
            success:
                (events, selectedIndex) =>
                    events.isEmpty
                        ? Center(
                          child: Text(
                            AppLocalizations.of(context)!.no_events_found,
                            style: AppStyles.bold20Primary,
                          ),
                        )
                        : ListView.builder(
                          itemBuilder: (context, index) {
                            return EventItem(
                              event: events[index],
                              onFavoritePressed: (Event value) {
                                context
                                    .read<EventCubit>()
                                    .updateIsFavoriteEvents(value, user!.id);
                              },
                            );
                          },
                          itemCount: events.length,
                        ),
            error:
                (message, _) => Center(
                  child: Text(message, style: AppStyles.bold20Primary),
                ),
          );
        },
      ),
    );
  }
}
