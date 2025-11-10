import 'package:evently/model/event.dart';
import 'package:evently/providers/event_list_provider.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/assets_manager.dart';

class EventItem extends StatelessWidget {
  final Event event;
  const EventItem({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
     var userProvider = Provider.of<UserProvider>(context);
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
          image: AssetImage( event.image),
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
                Text(event.date.day.toString(), style: AppStyles.bold20Primary),
                Text(DateFormat.MMM().format(event.date), style: AppStyles.bold16Primary),
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
                    event.title,
                    style: AppStyles.bold14Black,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: ( ) {
                  
                    Provider.of<EventListProvider>(context, listen: false)
                        .updateIsFavoriteEvents(event, context  , userProvider.user!.id );
                  },
                  icon: Image.asset(
                    event.isFavorite == true
                        ? AssetsManager.iconFavoriteSelected
                        : AssetsManager.iconFavorite,
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
