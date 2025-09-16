import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{


   ThemeMode _currentTheme =  ThemeMode.system;

   ThemeMode  get currentTheme => _currentTheme;


  void changeTheme(ThemeMode newTheme) {
    if (_currentTheme != newTheme) {
      _currentTheme = newTheme;
      notifyListeners();
    }
  }
}
