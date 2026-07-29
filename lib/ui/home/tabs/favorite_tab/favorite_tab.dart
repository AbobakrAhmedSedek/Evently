import 'package:evently/domain/model/event.dart';
import 'package:evently/domain/model/my_user.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:evently/ui/home/tabs/favorite_tab/cubit/favorite_action.dart';
import 'package:evently/ui/home/tabs/favorite_tab/cubit/favorite_cubit.dart';
import 'package:evently/ui/home/tabs/favorite_tab/cubit/favorite_state.dart';
import 'package:evently/ui/home/tabs/home_tab/widgets/event_item_widget.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:evently/utils/app_styles.dart';
import 'dart:async';

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({super.key});

  @override
  State<FavoriteTab> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  final ScrollController _scrollController = ScrollController();
  late final StreamSubscription<FavoriteAction> _actionSubscription;
  @override
  void dispose() {
    _actionSubscription.cancel();

    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _actionSubscription = context.read<FavoriteCubit>().actions.listen((
      action,
    ) {
      action.when(
        updateFavoriteFailed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update favorite')),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final user = context.select<UserProvider, MyUser?>((p) => p.user);
    debugPrint("FavoriteTab build");
    return BlocBuilder<FavoriteCubit, FavoriteState>(
      
      builder: (context, state) {
        debugPrint("BlocBuilder build");
        debugPrint("🔄 FavoriteTab Rebuild");

        final events = state.when(
          initial: () => [],
          loading: () => [],
          success: (events) => events,
          error: (message) => [],
        );

        debugPrint("UI Events Count: ${events.length}");

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
                  // حقل البحث
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
                          color: AppColors.primaryLight.withOpacity(0.9),
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
                            hintText:
                                AppLocalizations.of(context)!.search_event,
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

                  // قائمة الأحداث
                  SliverList(
                    delegate:
                        events.isEmpty
                            ? SliverChildListDelegate([
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.favorite_border,
                                        size: 100,
                                        color: Colors.grey.shade400,
                                      ),
                                      SizedBox(height: 24),
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.no_events_found,
                                        style: AppStyles.bold20Primary,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Add events to favorites to see them here',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              ),
                            ])
                            : SliverChildBuilderDelegate((context, index) {
                              return EventItem(
                                event: events[index],
                                onFavoritePressed: (Event value) {
                                  context
                                      .read<FavoriteCubit>()
                                      .updateIsFavoriteEvents(value, user!.id);
                                },
                              );
                            }, childCount: events.length),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
