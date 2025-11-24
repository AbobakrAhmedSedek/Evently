
import 'package:evently/model/my_user.dart';
import 'package:evently/providers/event_list_provider.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:evently/ui/authentication/login/login_screen.dart';
import 'package:evently/ui/home/home_screen.dart';
import 'package:evently/utils/firebase_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // عرض شاشة التحميل أثناء الانتظار
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        final bool isLoggedIn = snapshot.hasData;

        if (isLoggedIn) {
          return _buildAuthenticatedView(context, snapshot.data!);
        } else {
          return _buildUnauthenticatedView(context);
        }
      },
    );
  }

  /// شاشة التحميل
  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// واجهة المستخدم المسجل
  Widget _buildAuthenticatedView(BuildContext context, User user) {
    _loadUserData(context, user);
    return const HomeScreen();
  }

  /// واجهة المستخدم غير المسجل
  Widget _buildUnauthenticatedView(BuildContext context) {
    _handleLogout(context);
    return const LoginScreen();
  }

  /// تحميل بيانات المستخدم
  void _loadUserData(BuildContext context, User user) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final eventListProvider = Provider.of<EventListProvider>(context, listen: false);

      // تجنب إعادة التحميل إذا كان المستخدم نفسه
      if (userProvider.user?.id == user.uid) {
        return;
      }

      try {
        // تحميل بيانات المستخدم من Firebase
        final MyUser? userData = await FirebaseUtils.getUserById(user.uid);

        if (userData != null) {
          // تحديث بيانات المستخدم
          userProvider.updateUser(userData);

          // تحميل الأحداث الخاصة بالمستخدم
          eventListProvider.clearEvents();
          eventListProvider.getAllEvents(userData.id);
        } else {
          // معالجة حالة عدم وجود بيانات
          debugPrint('⚠️ لم يتم العثور على بيانات المستخدم: ${user.uid}');
        }
      } catch (e) {
        // معالجة الأخطاء
        debugPrint('❌ خطأ في تحميل بيانات المستخدم: $e');
      }
    });
  }

  /// معالجة تسجيل الخروج
  void _handleLogout(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.logout(context);
    });
  }
}



// ------------------------------------------------------------------------------
// import 'package:evently/model/my_user.dart';
// import 'package:evently/providers/event_list_provider.dart';
// import 'package:evently/providers/user_provider.dart';
// import 'package:evently/ui/authentication/login/login_screen.dart';
// import 'package:evently/ui/home/home_screen.dart';
// import 'package:evently/utils/firebase_utils.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         var userProvider = Provider.of<UserProvider>(context, listen: false);
//         var eventListProvider =
//             Provider.of<EventListProvider>(context, listen: false);

//         final bool isLoggedIn = snapshot.hasData;

//         if (isLoggedIn) {
//           final user = snapshot.data!;

//           WidgetsBinding.instance.addPostFrameCallback((_) async {
//             if (userProvider.user?.id == user.uid) return;

//             // Load user data
//             MyUser? userData = await FirebaseUtils.getUserById(user.uid);

//             if (userData != null) {
//               userProvider.updateUser(userData);

//               eventListProvider.clearEvents();
//               eventListProvider.getAllEvents(userData.id);
//             }
//           });

//           return const HomeScreen();
//         } else {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             userProvider.logout(context);
//           });

//           return LoginScreen();
//         }
//       },
//     );
//   }
// }
