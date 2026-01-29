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

