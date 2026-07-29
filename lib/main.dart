import 'package:evently/app/app_providers.dart';
import 'package:evently/app/my_app.dart';
import 'package:evently/firebase_options.dart';
import 'package:evently/utils/my_bloc_observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  Bloc.observer = MyBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(AppProviders(child: const MyApp()));
}
