import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Int64List highVibrationPattern =
      Int64List.fromList([0, 1000, 500, 1000, 500, 1000, 500, 1000]);

  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'task_channel',
          channelName: 'Task Notifications',
          channelDescription: 'Notifications for task reminders',
          defaultColor: Colors.deepOrange,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          locked: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelKey: 'task_alarm_channel',
          channelName: 'Task Alarm',
          channelDescription: 'Loud alarm notifications for tasks',
          defaultColor: Colors.deepOrange,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          enableVibration: true,
          vibrationPattern: highVibrationPattern,
          playSound: true,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          criticalAlerts: true,
          locked: true,
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications(
            permissions: [
              NotificationPermission.Alert,
              NotificationPermission.Sound,
              NotificationPermission.Badge,
              NotificationPermission.Vibration,
              NotificationPermission.Light,
              NotificationPermission.CriticalAlert,
              NotificationPermission.FullScreenIntent,
            ],
          );
        }
      },
    );

    // Set up background notification action handler
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Handle notification action here
    print('Notification action received: ${receivedAction.buttonKeyPressed}');
  }

  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    print('Notification created: ${receivedNotification.title}');
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    print('Notification displayed: ${receivedNotification.title}');
  }

  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('Notification dismissed: ${receivedAction.title}');
  }

  static Future<void> createTaskNotification({
    required String title,
    required String body,
    required DateTime scheduleTime,
  }) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    if (!isAllowed) {
      return;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: scheduleTime.millisecondsSinceEpoch.remainder(100000),
        channelKey: 'task_alarm_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        fullScreenIntent: true,
        category: NotificationCategory.Alarm,
        displayOnForeground: true,
        displayOnBackground: true,
        autoDismissible: false,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'STOP_ALARM',
          label: 'Stop Alarm',
          autoDismissible: true,
          showInCompactView: true,
        ),
      ],
      schedule: NotificationCalendar.fromDate(
        date: scheduleTime,
        preciseAlarm: true,
      ),
    );
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await AwesomeNotifications().cancel(id);
    } catch (e) {
      print('Error canceling notification: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}
