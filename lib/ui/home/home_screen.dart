import 'package:evently/ui/home/tabs/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../utils/assets_manager.dart';


class HomeScreen extends StatelessWidget {
  static const routeName = '/';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body:  Profile(),

    );
  }


}

// bottomNavigationBar: BottomNavigationBar(items: [
// builtBottomNavigationBarItem(icon: AssetsManager.iconHome, label: AppLocalizations.of(context)!.home,),
// builtBottomNavigationBarItem(icon: AssetsManager.iconMap, label: AppLocalizations.of(context)!.map,),
// builtBottomNavigationBarItem(icon: AssetsManager.iconFavorite, label: AppLocalizations.of(context)!.favorite,),
// builtBottomNavigationBarItem(icon: AssetsManager.iconProfile, label: AppLocalizations.of(context)!.profile,),
// ]),


// builtBottomNavigationBarItem({required icon, required label}) {
//   return BottomNavigationBarItem(
//     icon: ImageIcon(AssetImage(icon)),
//     label: label,
//   );
// }