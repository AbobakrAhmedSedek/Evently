import 'package:evently/utils/app_styles.dart';
import 'package:flutter/material.dart';

class EventDateOrTime extends StatelessWidget {
  final String iconDateOrTime;
  final String eventDateOrTime;
  final String chooseDateOrTime;
  final Function onChooseDateOrTime;
  const EventDateOrTime({
    super.key,
     required this.iconDateOrTime,
    required this.eventDateOrTime,
    required this.chooseDateOrTime,
    required this.onChooseDateOrTime,
  });
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Image.asset(iconDateOrTime),
          SizedBox(width:width  * 0.02),
        Text(eventDateOrTime, style: AppStyles.medium16Black),
        Spacer(),
        TextButton(
          onPressed: () {
            onChooseDateOrTime();
          },
          
          child:Text(chooseDateOrTime, style: AppStyles.medium16Primary ,),
        ),
      ],
    );
  }
}
