import 'package:flutter/material.dart';

enum NotificationMode { Interval, Custom }

class NotificationSettings {
  const NotificationSettings({
    @required this.isNotificationTurnOn,
    @required this.notificationMode,
    @required this.totalActiveNotifications,
    @required this.intervalTimeHour,
    @required this.intervalTimeMinute,
    @required this.isIgnoringBatteryOptimizations,
  });

  final bool isNotificationTurnOn;
  final NotificationMode notificationMode;
  final int totalActiveNotifications;
  final int intervalTimeHour;
  final int intervalTimeMinute;
  final bool isIgnoringBatteryOptimizations;
}
