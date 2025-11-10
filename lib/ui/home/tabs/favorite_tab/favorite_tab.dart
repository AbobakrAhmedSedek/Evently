//todo:  new code
import 'package:evently/providers/event_list_provider.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:evently/ui/home/tabs/home_tab/widgets/event_item.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:provider/provider.dart';

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({super.key});

  @override
  State<FavoriteTab> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context ) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    var eventListProvider = Provider.of<EventListProvider>(context);
    var userProvider = Provider.of<UserProvider>(context);
    if (eventListProvider.favoriteEventsList.isEmpty) {
      eventListProvider.getAllfavoriteEvents( userProvider.user!.id );
        }
    return Scaffold(
      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          radius: const Radius.circular(10),
          thickness: 6,
          interactive: true,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ✅ حقل البحث مثبت في الأعلى
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchHeaderDelegate(
                  minHeight: 70,
                  maxHeight: 70,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: width * 0.05,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(
                        0.9,
                      ), // ✅ شبه شفاف
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      style: AppStyles.medium16White,
                      cursorColor: AppColors.whiteColor,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.search_event,
                        hintStyle: AppStyles.medium16White,
                        border: InputBorder.none,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            AssetsManager.iconSearch,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: height * 0.01)),

              SliverList(
                delegate:
                    eventListProvider.favoriteEventsList.isEmpty
                        ? SliverChildListDelegate([
                          Center(
                            child: Text(
                              AppLocalizations.of(context)!.no_events_found,
                              style: AppStyles.bold20Primary,
                            ),
                          ),
                        ])
                        : SliverChildBuilderDelegate(
                          (context, index) {
                            return EventItem(
                              event:
                                  eventListProvider.favoriteEventsList[index],
                            );
                          },
                          childCount:
                              eventListProvider.favoriteEventsList.length,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SearchHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_SearchHeaderDelegate oldDelegate) {
    return oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.child != child;
  }
}

//todo:  old code
// import 'package:evently/utils/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import '../../widgets/custom_text_field.dart';
// import 'package:evently/utils/assets_manager.dart';
// import 'package:evently/utils/app_styles.dart';
// import 'package:evently/ui/home/tabs/home_tab/widgets/event_item.dart';
// class FavoriteTab extends StatelessWidget {
//   const FavoriteTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     var width = MediaQuery
//         .of(context)
//         .size
//         .width;
//     var height = MediaQuery
//         .of(context)
//         .size
//         .height;
//     return Scaffold(
//         body: SafeArea(
//           child: Column(
//             children: [
//               // SizedBox(height: height * 0.06),
//               Padding(
//                 padding:  EdgeInsets.symmetric(horizontal:  width* 0.05),
//                 child: CustomTextField(
//                     borderColor: AppColors.primaryLight,
//                     hintText: AppLocalizations.of(context)!.search_event,
//                   hintStyle:  AppStyles.medium16Primary,
//                     prefixIcon:Image.asset(AssetsManager.iconSearch, ),
//
//                 ),
//               ),
//               SizedBox(height: height * 0.01),
//               Expanded(
//                 child: ListView.builder(
//                   itemBuilder: (BuildContext context, int index) {
//                     return const EventItem();
//                   },
//                   itemCount: 5,
//                 ),
//               ),
//             ],
//           ),
//         )
//     );
//   }
// }
