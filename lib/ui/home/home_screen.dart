

import 'package:evently/ui/home/tabs/favorite_tab/favorite_tab.dart';
import 'package:evently/ui/home/tabs/home_tab/home_tab.dart';
import 'package:evently/ui/home/tabs/map_tab/map_tab.dart';
import 'package:evently/ui/home/tabs/profile_tab/profile_tab.dart'; // ✅ تعديل هنا
import 'package:evently/ui/home/add_event.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../utils/assets_manager.dart';
import 'dart:math' as math; // ✅ إضافة هنا
// ✅ CustomClipper لعمل الـ notch
// class NotchClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     final centerX = size.width / 2;
//     final notchRadius = 35.0;
//
//     // بداية المسار من اليسار
//     path.lineTo(centerX - notchRadius - 10, 0);
//
//     // منحنى الـ notch
//     path.quadraticBezierTo(
//       centerX - notchRadius, 0,
//       centerX - notchRadius, notchRadius / 2,
//     );
//     path.quadraticBezierTo(
//       centerX - notchRadius, notchRadius,
//       centerX, notchRadius,
//     );
//     path.quadraticBezierTo(
//       centerX + notchRadius, notchRadius,
//       centerX + notchRadius, notchRadius / 2,
//     );
//     path.quadraticBezierTo(
//       centerX + notchRadius, 0,
//       centerX + notchRadius + 10, 0,
//     );
//     //
//     // // باقي المسار
//     path.lineTo(size.width, 0);
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.close();
//
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
class NotchClipper extends CustomClipper<Path> {
  final double notchRadius;

  NotchClipper({this.notchRadius = 35.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final centerX = size.width / 2;

    // بداية المسار من اليسار
    path.lineTo(centerX - notchRadius, 0);

    // رسم نصف دائرة (arcTo) يمثل النوتش
    Rect notchRect = Rect.fromCircle(
      center: Offset(centerX, 0),
      radius: notchRadius,
    );

    // arcTo: تبدأ من الزاوية العلوية اليسرى للقوس وتعمل نصف دائرة لتحت
    path.arcTo(
      notchRect,
      math.pi, // يبدأ من 180 درجة (جهة اليسار)
      -math.pi, // يرسم نصف دائرة باتجاه عقارب الساعة
      false,
    );

    // باقي المسار
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HomeScreen extends StatefulWidget {
  static const routeName = '/';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  List<Widget> pages = [
    HomeTab(),
    MapTab(),
    FavoriteTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pages[selectedIndex],
      bottomNavigationBar: _buildClippedBottomBar(),
      floatingActionButton: _buildCustomFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildClippedBottomBar() {
    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          // الخلفية مع الـ clip
          ClipPath(
            clipper: NotchClipper(),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.26),
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
            ),
          ),

          // أيقونات التنقل
          Container(
            height: 80,
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildNavIcon(
                  index: 0,
                  selectedIcon: AssetsManager.iconHomeSelected,
                  unSelectedIcon: AssetsManager.iconHome,
                  label: AppLocalizations.of(context)!.home,
                ),
                buildNavIcon(
                  index: 1,
                  selectedIcon: AssetsManager.iconMapSelected,
                  unSelectedIcon: AssetsManager.iconMap,
                  label: AppLocalizations.of(context)!.map,
                ),
                SizedBox(width: 70), // مساحة للـ FAB
                buildNavIcon(
                  index: 2,
                  selectedIcon: AssetsManager.iconFavoriteSelected,
                  unSelectedIcon: AssetsManager.iconFavorite,
                  label: AppLocalizations.of(context)!.favorite,
                ),
                buildNavIcon(
                  index: 3,
                  selectedIcon: AssetsManager.iconProfileSelected,
                  unSelectedIcon: AssetsManager.iconProfile,
                  label: AppLocalizations.of(context)!.profile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomFAB() {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32.5),
          onTap: () {
            Navigator.of(context).pushNamed(AddEvent.routeName);
          },
          child: Icon(
            Icons.add,
            color: AppColors.whiteColor,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget buildNavIcon({
    required int index,
    required String selectedIcon,
    required String unSelectedIcon,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.black : Colors.white;
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              transform: Matrix4.translationValues(0, isSelected ? -5 : 0, 0),
              child: ImageIcon(
                AssetImage(isSelected ? selectedIcon : unSelectedIcon),
                color: isSelected ? iconColor : iconColor.withOpacity(0.6),
                size: isSelected ? 28 : 24,
              ),
            ),
            SizedBox(height: 4),
            AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: isSelected ? 1.0 : 0.6,
              child: Text(
                label,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: isSelected ? 12 : 10,
                  color: AppColors.whiteColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



//todo: old code
// import 'package:evently/ui/home/tabs/favorite_tab/favorite_tab.dart';
// import 'package:evently/ui/home/tabs/home_tab/home_tab.dart';
// import 'package:evently/ui/home/tabs/map_tab/map_tab.dart';
// import 'package:evently/ui/home/tabs/profile_tab/profile_Tab.dart';
// import 'package:evently/utils/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import '../../../utils/assets_manager.dart';
//
// class HomeScreen extends StatefulWidget {
//   static const routeName = '/';
//
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int selectedIndex = 0;
//   List<Widget> pages = [
//     HomeTab(),
//     MapTab(),
//     FavoriteTab(),
//     ProfileTab(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // ✅ إضافة extendBody عشان الـ body يمتد وراء الـ bottom bar
//       extendBody: true,
//
//       bottomNavigationBar: BottomAppBar(
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 10.0, // ✅ زيادة المسافة للـ notch الشفاف
//         color: Theme.of(context).primaryColor,
//         elevation: 10, // ✅ إضافة shadow
//         child: Container(
//           height: 65, // ✅ تحديد ارتفاع واضح
//           padding: EdgeInsets.symmetric(horizontal: 20), // ✅ إضافة padding
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               buildNavIcon(
//                 index: 0,
//                 selectedIcon: AssetsManager.iconHomeSelected,
//                 unSelectedIcon: AssetsManager.iconHome,
//                 label: AppLocalizations.of(context)!.home,
//               ),
//               buildNavIcon(
//                 index: 1,
//                 selectedIcon: AssetsManager.iconMapSelected,
//                 unSelectedIcon: AssetsManager.iconMap,
//                 label: AppLocalizations.of(context)!.map,
//               ),
//               // ✅ مساحة أكبر للـ FAB
//               const SizedBox(width: 50),
//               buildNavIcon(
//                 index: 2,
//                 selectedIcon: AssetsManager.iconFavoriteSelected,
//                 unSelectedIcon: AssetsManager.iconFavorite,
//                 label: AppLocalizations.of(context)!.favorite,
//               ),
//               buildNavIcon(
//                 index: 3,
//                 selectedIcon: AssetsManager.iconProfileSelected,
//                 unSelectedIcon: AssetsManager.iconProfile,
//                 label: AppLocalizations.of(context)!.profile,
//               ),
//             ],
//           ),
//         ),
//       ),
//
//       // ✅ تحسين الـ FloatingActionButton
//       floatingActionButton: Container(
//         width: 60,
//         height: 60,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 8,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: FloatingActionButton(
//           onPressed: () {
//             // ✅ إضافة الإجراء المطلوب هنا
//           },
//           backgroundColor: Theme.of(context).primaryColor,
//           elevation: 0, // لأننا عملنا shadow في الـ Container
//           child: const Icon(Icons.add, color: AppColors.whiteColor, size: 32),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
//
//       body: pages[selectedIndex],
//     );
//   }
//
//   Widget buildNavIcon({
//     required int index,
//     required String selectedIcon,
//     required String unSelectedIcon,
//     required String label,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final iconColor = isDark ? Colors.black : Colors.white;
//     final isSelected = selectedIndex == index;
//
//     return GestureDetector(
//       onTap: () => setState(() => selectedIndex = index),
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ✅ إضافة تأثير حركي للأيقونة المحددة
//             AnimatedContainer(
//               duration: Duration(milliseconds: 200),
//               transform: Matrix4.translationValues(0, isSelected ? -3 : 0, 0),
//               child: ImageIcon(
//                 AssetImage(isSelected ? selectedIcon : unSelectedIcon),
//                 color: isSelected ? iconColor : iconColor.withOpacity(0.7),
//                 size: 28,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               label,
//               style: Theme.of(context).textTheme.headlineLarge?.copyWith(
//                 fontSize: 12,
//                 color: isSelected
//                     ? AppColors.whiteColor
//                     : AppColors.whiteColor.withOpacity(0.7),
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

