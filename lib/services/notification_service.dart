import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
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
          locked: true, // Prevent user from dismissing notification
          criticalAlerts: true, // Enable critical alerts that bypass DND
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

  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Handle notification action here
    print('Notification action received: ${receivedAction.buttonKeyPressed}');
  }

  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    print('Notification created: ${receivedNotification.title}');
  }

  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    print('Notification displayed: ${receivedNotification.title}');
  }

  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
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
      print('Notification permission denied');
      return;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: scheduleTime.millisecondsSinceEpoch.remainder(100000),
        channelKey: 'task_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        criticalAlert: true,
        wakeUpScreen: true,
        fullScreenIntent: true,
        category: NotificationCategory.Alarm,
      ),
      schedule: NotificationCalendar(
        year: scheduleTime.year,
        month: scheduleTime.month,
        day: scheduleTime.day,
        hour: scheduleTime.hour,
        minute: scheduleTime.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
        preciseAlarm: true, // Use exact alarm timing
        allowWhileIdle: true, // Allow notification when device is idle
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