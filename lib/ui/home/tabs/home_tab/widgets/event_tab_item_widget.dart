import 'package:evently/utils/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart';

class EventTabItemWidget extends StatelessWidget {
  final String eventName;
  final bool isSelected;
  final IconData iconData;

  const EventTabItemWidget({
    super.key,
    required this.iconData,
    required this.eventName,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.009,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(46),
        color: isDark
            ? isSelected
            ? AppColors.primaryLight
            : Colors.transparent
            : isSelected
            ? AppColors.whiteColor
            : Colors.transparent,
        border: Border.all(
          color: isDark ? AppColors.primaryLight : AppColors.whiteColor,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 18,
            color: isDark
                ? Colors.white
                : isSelected
                ? AppColors.primaryLight
                : Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            eventName,
            style: isDark
                ? AppStyles.medium16White
                : isSelected
                ? AppStyles.medium16Primary
                : AppStyles.medium16White,
          ),
        ],
      ),
    );
  }
}
