import 'package:evently/providers/add_event_provider.dart';
import 'package:evently/providers/event_list_provider.dart';
import 'package:evently/providers/language_provider.dart';
import 'package:evently/providers/maps_tab_provider.dart';
import 'package:evently/providers/theme_provider.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => EventListProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<EventListProvider, MapsTabProvider>(
          create:
              (context) => MapsTabProvider(context.read<EventListProvider>()),
          update:
              (context, eventListProvider, previous) =>
                  previous ?? MapsTabProvider(eventListProvider),
        ),
        ChangeNotifierProvider(create: (_) => AddEventProvider()),
      ],
      child: child,
    );
  }
}
