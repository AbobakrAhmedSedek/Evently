import 'package:evently/providers/user_provider.dart';
import 'package:evently/ui/home/tabs/profile_tab/widgets/theme_bottom_sheet.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/firebase_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../providers/language_provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../utils/app_colors.dart';
import 'widgets/language_bottom_sheet.dart';
import 'widgets/profile_appbar_widget.dart';
import 'package:evently/ui/authentication/login/login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var languageProvider = Provider.of<LanguageProvider>(context);
    var themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: ProfileAppbarWidget(),
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
            Spacer( flex: 4,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: height * 0.015,
                ),
              ),
              onPressed: () {
                FirebaseUtils.logout();
                // Provider.of<UserProvider>(context, listen: false).logout(context);
                //   Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
                  
              },
              child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.logout, color: Colors.white,size: 30,),

                  SizedBox(width: width * 0.02),
                  Text(
                    AppLocalizations.of(context)!.logout,
                    style: AppStyles.regular20White,
                  ),
                ],
              ),
            ),
            Spacer( flex: 2,),
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

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../providers/language_provider.dart';
// import '../../../../providers/theme_provider.dart';
// import '../../../../utils/app_colors.dart';
// import '../../../../utils/assets_manager.dart';
// import 'widgets/language_bottom_sheet.dart';
// import 'widgets/theme_bottom_sheet.dart';
//
// class ProfileTab extends StatefulWidget {
//   const ProfileTab({super.key});
//
//   @override
//   State<ProfileTab> createState() => _ProfileTabState();
// }
//
// class _ProfileTabState extends State<ProfileTab> {
//   File? userImage;
//
//   Future<void> pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? file = await picker.pickImage(source: ImageSource.gallery);
//     if (file != null) {
//       setState(() {
//         userImage = File(file.path);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;
//     var languageProvider = Provider.of<LanguageProvider>(context);
//     var themeProvider = Provider.of<ThemeProvider>(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryLight,
//         toolbarHeight: height * 0.18,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(bottomLeft: Radius.circular(70)),
//         ),
//         title: Row(
//           children: [
//             GestureDetector(
//               onTap: pickImage,
//               child: Container(
//                 height: height * 0.15,
//                 width: height * 0.15,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     bottomRight: Radius.circular(80),
//                     topRight: Radius.circular(80),
//                     bottomLeft: Radius.circular(80),
//                   ),
//                 ),
//                 child: Container(
//                   margin: const EdgeInsets.all(8.0),
//                   decoration: const BoxDecoration(shape: BoxShape.circle),
//                   child: userImage == null
//                       ? ClipOval(
//                     child: Image.asset(
//                       AssetsManager.imageProfile, // ← صورتك الافتراضية
//                       fit: BoxFit.cover,
//                     ),
//                   )
//                       : ClipOval(
//                     child: Image.file(
//                       userImage!, // ← الصورة اللي اختارها المستخدم
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               AppLocalizations.of(context)!.language,
//               style: Theme.of(context).textTheme.headlineLarge,
//             ),
//             InkWell(
//               onTap: () {
//                 showLanguageBottomSheet(context: context);
//               },
//               child: Container(
//                 margin: const EdgeInsets.all(16),
//                 padding: EdgeInsets.symmetric(
//                   horizontal: width * 0.01,
//                   vertical: height * 0.01,
//                 ),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: AppColors.primaryLight, width: 2),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       languageProvider.currentLocale.languageCode == 'en'
//                           ? AppLocalizations.of(context)!.english
//                           : AppLocalizations.of(context)!.arabic,
//                       style: Theme.of(context).textTheme.headlineLarge,
//                     ),
//                     const Icon(
//                       Icons.arrow_drop_down,
//                       color: AppColors.primaryLight,
//                       size: 35,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: height * 0.02),
//             Text(
//               AppLocalizations.of(context)!.theme,
//               style: Theme.of(context).textTheme.headlineLarge,
//             ),
//             InkWell(
//               onTap: () {
//                 showThemeBottomSheet(context: context);
//               },
//               child: Container(
//                 margin: const EdgeInsets.all(16),
//                 padding: EdgeInsets.symmetric(
//                   horizontal: width * 0.01,
//                   vertical: height * 0.01,
//                 ),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: AppColors.primaryLight, width: 2),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       themeProvider.currentTheme == ThemeMode.light
//                           ? AppLocalizations.of(context)!.light
//                           : AppLocalizations.of(context)!.dark,
//                       style: Theme.of(context).textTheme.headlineLarge,
//                     ),
//                     const Icon(
//                       Icons.arrow_drop_down,
//                       color: AppColors.primaryLight,
//                       size: 35,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void showLanguageBottomSheet({required BuildContext context}) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => const LanguageBottomSheet(),
//     );
//   }
//
//   void showThemeBottomSheet({required BuildContext context}) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => const ThemeBottomSheet(),
//     );
//   }
// }
