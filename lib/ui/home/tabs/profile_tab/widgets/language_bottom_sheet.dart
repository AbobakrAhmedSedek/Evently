import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/language_provider.dart';
import '../../../../../utils/app_colors.dart';

class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var languageProvider = Provider.of<LanguageProvider>(context);

    // تحديد اللغة الحالية
    String currentLanguage = languageProvider.currentLocale.languageCode ?? 'en';

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
              languageProvider.changeLocale(const Locale('ar'));
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.arabic,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: currentLanguage == 'ar'
                        ? AppColors.primaryLight
                        : Theme.of(context).textTheme.headlineMedium?.color,
                  ),
                ),
                // إظهار علامة الصح فقط للغة المختارة
                currentLanguage == 'ar'
                    ? Icon(Icons.check, color: AppColors.primaryLight, size: 35)
                    : SizedBox(width: 35), // مساحة فارغة للحفاظ على التخطيط
              ],
            ),
          ),
          SizedBox(height: height * 0.04),
          // خيار اللغة الإنجليزية
          InkWell(
            onTap: () {
              languageProvider.changeLocale(const Locale('en'));
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.english,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: currentLanguage == 'en'
                        ? AppColors.primaryLight
                        : Theme.of(context).textTheme.headlineMedium?.color,
                  ),
                ),
                // إظهار علامة الصح فقط للغة المختارة
                currentLanguage == 'en'
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
