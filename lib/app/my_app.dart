import 'package:evently/app/auth_wrapper.dart';
import 'package:evently/domain/model/event.dart';
import 'package:evently/ui/authentication/login/login_screen.dart';
import 'package:evently/ui/authentication/register_screen/register_screen.dart';
import 'package:evently/ui/home/create_event/add_event.dart';
import 'package:evently/ui/home/create_event/pick_location_screen.dart';
import 'package:evently/ui/home/event_details/event_details_screen.dart';
import 'package:evently/ui/home/home_screen.dart';
import 'package:evently/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var languageProvider = Provider.of<LanguageProvider>(context);
    var themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        AddEvent.routeName: (context) {
           Event? event =
              ModalRoute.of(context)!.settings.arguments as Event?;
          return AddEvent(event: event);
        },
        LoginScreen.routeName: (_) => LoginScreen(),
        RegisterScreen.routeName: (_) => RegisterScreen(),
        PickLocationScreen.routeName: (_) => const PickLocationScreen(),
        EventDetailsScreen.routeName:
            (context) => EventDetailsScreen(
              event: ModalRoute.of(context)!.settings.arguments as Event,
            ),
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: languageProvider.currentLocale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.currentTheme,
    );
  }
}
