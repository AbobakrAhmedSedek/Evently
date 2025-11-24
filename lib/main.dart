import 'package:evently/app/app_providers.dart';
import 'package:evently/app/my_app.dart';
import 'package:evently/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    AppProviders(
      child: const MyApp(),
    ),
  );
}


// ------------------------------------------------------------------------------
// import 'package:evently/model/my_user.dart';
// import 'package:evently/providers/add_event_provider.dart';
// import 'package:evently/providers/event_list_provider.dart';
// import 'package:evently/providers/language_provider.dart';
// import 'package:evently/providers/maps_tab_provider.dart';
// import 'package:evently/providers/theme_provider.dart';
// import 'package:evently/providers/user_provider.dart';
// import 'package:evently/ui/authentication/login/login_screen.dart';
// import 'package:evently/ui/authentication/register_screen/register_screen.dart';
// import 'package:evently/ui/home/create_event/add_event.dart';
// import 'package:evently/ui/home/create_event/pick_location_screen.dart';
// import 'package:evently/ui/home/home_screen.dart';
// import 'package:evently/utils/app_theme.dart';
// import 'package:evently/utils/firebase_utils.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:provider/provider.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const EventlyApp());
// }

// class EventlyApp extends StatelessWidget {
//   const EventlyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => LanguageProvider()),
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//         ChangeNotifierProvider(create: (_) => EventListProvider()),
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//         ChangeNotifierProvider(create: (_) => MapsTabProvider()),
//         ChangeNotifierProvider(create: (_) => AddEventProvider()),
//       ],
//       child: const MyApp(),
//     );
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var languageProvider = Provider.of<LanguageProvider>(context);
//     var themeProvider = Provider.of<ThemeProvider>(context);

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const AuthWrapper(),
//       routes: {
//         HomeScreen.routeName: (context) => const HomeScreen(),
//         AddEvent.routeName: (context) => const AddEvent(),
//         LoginScreen.routeName: (context) => LoginScreen(),
//         RegisterScreen.routeName: (context) => RegisterScreen(),
//         PickLocationScreen.routeName: (context) => const PickLocationScreen(),
//       },
//       localizationsDelegates: AppLocalizations.localizationsDelegates,
//       supportedLocales: AppLocalizations.supportedLocales,
//       locale: languageProvider.currentLocale,
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: themeProvider.currentTheme,
//     );
//   }
// }

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
//         var eventListProvider = Provider.of<EventListProvider>(
//           context,
//           listen: false,
//         );
//         final bool isLoggedIn = snapshot.hasData;

//         if (isLoggedIn) {
//           final user = snapshot.data!;
//           WidgetsBinding.instance.addPostFrameCallback((_) async {
//             try {
//               // منع الطلب المتكرر لو نفس المستخدم موجود بالفعل
//               if (userProvider.user?.id == user.uid) return;

//               // جلب بيانات المستخدم من Firestore
//               MyUser? userData = await FirebaseUtils.getUserById(user.uid);

//               if (userData != null) {
//                 // تحديث بيانات المستخدم
//                 userProvider.updateUser(userData);

//                 // تحميل أحداث المستخدم الجديد
//                 eventListProvider.clearEvents();
//                 eventListProvider.getAllEvents(userData.id);
//               }
//             } catch (e) {
//               // سجل الخطأ أو أظهر رسالة مناسبة
//               debugPrint('Failed to load user data: $e');
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


