import 'package:evently/providers/event_list_provider.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:evently/ui/home/create_event/add_event.dart';
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
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _lastUserId;
  UserProvider? _userProvider;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ إضافة listener مرة واحدة فقط
      if (_userProvider == null) {
        _userProvider = Provider.of<UserProvider>(context, listen: false);

        // ✅ استمع للتغييرات
        _userProvider!.addListener(_onUserChanged);

        // ✅ تحقق من الحالة الحالية
        _onUserChanged();
      }
    });
  }


  // ✅ دالة منفصلة للتعامل مع تغيير User
  void _onUserChanged() {
    final user = _userProvider?.user;

    print('👤 User changed: ${user?.id ?? "null"}');

    if (user != null &&
        !_hasLoadedOnce &&
        !_isLoading &&
        _lastUserId != user.id) {
      print('✅ Loading favorites...');
WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadFavorites();
      });
    }
  }

  Future<void> _loadFavorites() async {
    print('🔄 _loadFavorites() called');

    final eventListProvider = Provider.of<EventListProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // ✅ Double check
    if (userProvider.user == null) {
      print('❌ User is null, aborting');
      return;
    }

    if (_isLoading) {
      print('⚠️ Already loading, skipping');
      return;
    }

    // ✅ تسجيل userId
    _lastUserId = userProvider.user!.id;

    setState(() => _isLoading = true);

    try {
      print('📡 Fetching favorites for: ${userProvider.user!.id}');

      // ✅ التحميل
      await eventListProvider.getAllFavoriteEvents(userProvider.user!.id);

      print(
        '✅ Favorites loaded: ${eventListProvider.favoriteEventsList.length} events',
      );

      // ✅ تسجيل نجاح التحميل
      _hasLoadedOnce = true;
    } catch (e) {
      print('❌ Error loading favorites: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load favorites'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  _hasLoadedOnce = false;
                  _lastUserId = null;
                });
                _loadFavorites();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    // ✅ مهم جدًا! إزالة الـ listener
    _userProvider?.removeListener(_onUserChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Consumer2<EventListProvider, UserProvider>(
      builder: (context, eventProvider, userProvider, child) {
        print(
          '🎨 Building UI - User: ${userProvider.user?.id ?? "null"}, '
          'Favorites: ${eventProvider.favoriteEventsList.length}, '
          'Loading: $_isLoading',
        );

        // ✅ إذا User null، عرض Loading
        if (userProvider.user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryLight),
                SizedBox(height: 16),
                Text(
                  'Loading user data...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // ✅ عرض Loading أثناء التحميل
        if (_isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryLight),
                SizedBox(height: 16),
                Text(
                  'Loading favorites...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
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
                        eventProvider.favoriteEventsList.isEmpty
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
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _hasLoadedOnce = false;
                                            // _lastUserId = null;
                                          });
                                          _onUserChanged();
                                        },
                                        icon: Icon(Icons.refresh),
                                        label: Text('Reload'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ])
                            : SliverChildBuilderDelegate(
                              (context, index) {
                                return EventItem(
                                  event:
                                      eventProvider.favoriteEventsList[index],
                                );
                              },
                              childCount:
                                  eventProvider.favoriteEventsList.length,
                            ),
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
