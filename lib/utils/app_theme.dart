import 'package:evently/utils/app_styles.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: AppColors.whiteColor,
      textTheme: TextTheme(
          headlineLarge: AppStyles.bold20Black,
          headlineMedium: AppStyles.bold20Black
      )
  );
  static final ThemeData darkTheme = ThemeData(
      scaffoldBackgroundColor: AppColors.primaryDark,
      textTheme: TextTheme(
          headlineLarge: AppStyles.bold20White,
          headlineMedium: AppStyles.bold20Black
      )
  );
}


