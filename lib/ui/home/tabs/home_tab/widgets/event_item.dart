import 'package:evently/utils/app_styles.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/assets_manager.dart';

class EventItem extends StatelessWidget {
  const EventItem({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.25,
      width: width * 0.9,
      margin: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: height * 0.01,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryLight),
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(AssetsManager.birthdayImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width * 0.13,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.whiteColor,
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Column(
              children: [
                Text("22", style: AppStyles.bold20Primary),
                Text("Nov", style: AppStyles.bold16Primary),
              ],
            ),
          ),
          Spacer(),

          Container(
            // height: height * 0.05,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withOpacity(0.7),
              //    Theme.of(context).primaryColor . withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "This is a Birthday Party  ",
                    style: AppStyles.bold14Black,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    AssetsManager.iconFavoriteSelected,
                    color: AppColors.primaryLight,
                    width: 30,
                    height: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
