import 'package:evently/utils/app_styles.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      showUnselectedLabels: true,
      selectedItemColor: AppColors.whiteColor,
      unselectedLabelStyle: AppStyles.bold16White,
      selectedLabelStyle: AppStyles.bold16White,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.whiteColor, width: 4),
      ),
    ),
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: AppColors.whiteColor,
    textTheme: TextTheme(
      headlineLarge: AppStyles.bold20Black,
      headlineMedium: AppStyles.bold20Black,
    ),
  );
  static final ThemeData darkTheme = ThemeData(
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      showUnselectedLabels: true,
      selectedItemColor: AppColors.whiteColor,
      unselectedLabelStyle: AppStyles.bold16White,
      selectedLabelStyle: AppStyles.bold16White,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryDark,
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.whiteColor, width: 4),
      ),
    ),
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.primaryDark,
    textTheme: TextTheme(
      headlineLarge: AppStyles.bold20White,
      headlineMedium: AppStyles.bold20Black,

    ),
  );
}
