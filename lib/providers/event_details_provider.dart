import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailsProvider extends ChangeNotifier {
  String formatDate(DateTime date) {
    DateFormat formatter = DateFormat(' dd MMMM yyyy');
    return formatter.format(date);
  }
  String formatTime(String time) {
    DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(formatter.parse(time));
  }
    
}
