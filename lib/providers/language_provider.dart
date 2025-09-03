import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier{


  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  void changeLocale(Locale newLocale) {
    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;
      notifyListeners();
    }
  }
}
