import 'package:flutter/material.dart';

/// موديل يمثل كل Tab (الاسم + الأيقونة)
class EventData {
  final String name;
  final IconData icon;

  const EventData({
    required this.name,
    required this.icon,
  });
}
