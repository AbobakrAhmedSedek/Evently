import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../providers/theme_provider.dart';
import '../../../../utils/app_colors.dart';

class ThemeBottomSheet extends StatelessWidget {
  const ThemeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var themeProvider = Provider.of<ThemeProvider>(context);


    ThemeMode  currentTheme = themeProvider.currentTheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.08,
        vertical: height * 0.04,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // خيار اللغة العربية
          InkWell(
            onTap: () {
              themeProvider .changeTheme( ThemeMode.light);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.light,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: currentTheme ==   ThemeMode. light
                        ? AppColors.primaryLight
                        : Theme.of(context).textTheme.headlineMedium?.color,
                  ),
                ),
                // إظهار علامة الصح فقط للغة المختارة
                currentTheme == ThemeMode.light
                    ? Icon(Icons.check, color: AppColors.primaryLight, size: 35)
                    : SizedBox(width: 35), // مساحة فارغة للحفاظ على التخطيط
              ],
            ),
          ),
          SizedBox(height: height * 0.04),

          InkWell(
            onTap: () {
              themeProvider.changeTheme( ThemeMode.dark) ;
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!. dark,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: currentTheme ==  ThemeMode.dark
                        ? AppColors.primaryLight
                        : Theme.of(context).textTheme.headlineMedium?.color,
                  ),
                ),
                // إظهار علامة الصح فقط للغة المختارة
                currentTheme ==    ThemeMode.dark
                    ? Icon(Icons.check, color: AppColors.primaryLight, size: 35)
                    : SizedBox(width: 35), // مساحة فارغة للحفاظ على التخطيط
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// getSelectedItemWidget( context, AppLocalizations.of(context)!.arabic),

// Widget getSelectedItemWidget(BuildContext context,  String language) {
// return Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// Text(
// language ,
// style: Theme.of(
// context,
// ).textTheme.headlineLarge?.copyWith(color: AppColors.primaryLight),
// ),
// Icon(Icons.check, color: AppColors.primaryLight, size: 35),
// ],
// );
// }
