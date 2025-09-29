import 'package:flutter/material.dart';

class EventTabItemWidget extends StatelessWidget {
  final String eventName;
  final bool isSelected;
  final IconData iconData;
  final Color selectedBackgroundColor;
  final Color unselectedBackgroundColor;
  final Color borderColor;
  final Color selectedIconColor;
  final Color unselectedIconColor;
  final TextStyle unselectedTextStyle;
  final TextStyle selectedTextStyle;

  const EventTabItemWidget({
    super.key,
    required this.iconData,
    required this.eventName,
    required this.isSelected,
    required this.selectedBackgroundColor,
    required this.unselectedBackgroundColor,
    required this.selectedIconColor,
    required this.unselectedTextStyle,
    required this.unselectedIconColor,
    required this.selectedTextStyle,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.009,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(46),
        color: isSelected ? selectedBackgroundColor : unselectedBackgroundColor,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 18,
            color: isSelected ? selectedIconColor : unselectedIconColor,
          ),
          const SizedBox(width: 6),
          Text(
            eventName,
            style:
                isSelected
                    ? selectedTextStyle
                    : unselectedTextStyle,
          ),
        ],
      ),
    );
  }
}
