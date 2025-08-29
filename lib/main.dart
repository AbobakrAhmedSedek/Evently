import 'package:evently/ui/home/home_screen.dart';
import 'package:evently/utils/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:  false,
      initialRoute: '/',
routes: {
        '/': (context) => const HomeScreen(),

},
    );
  }
}
