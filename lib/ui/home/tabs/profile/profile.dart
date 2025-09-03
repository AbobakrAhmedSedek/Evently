import 'package:evently/ui/home/tabs/profile/theme_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';


import '../../../../providers/language_provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../utils/app_colors.dart';
import 'language_bottom_sheet.dart';


class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var languageProvider = Provider.of<LanguageProvider>(context);
    var themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.language,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            InkWell(
              onTap: () {
                showLanguageBottomSheet(context: context);
              },
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.01,
                  vertical: height * 0.01,
                ),

                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryLight, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      languageProvider.currentLocale.languageCode == 'en'
                          ? AppLocalizations.of(context)!.english
                          : AppLocalizations.of(context)!.arabic,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primaryLight,
                      size: 35,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: height * 0.02),
            Text(
              AppLocalizations.of(context)!.theme,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            InkWell(
              onTap: () {
                showThemeBottomSheet(context: context);
              },
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.01,
                  vertical: height * 0.01,
                ),

                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryLight, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    // todo : change text according to theme
                    Text(
                      themeProvider.currentTheme == ThemeMode.light
                          ? AppLocalizations.of(context)!.light
                          : AppLocalizations.of(context)!.dark,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primaryLight,
                      size: 35,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showLanguageBottomSheet({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => LanguageBottomSheet(),
    );
  }

  void showThemeBottomSheet({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ThemeBottomSheet(),
    );
  }
}
