import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:network_info/controller/secure_storage_controller.dart';
import 'package:network_info/utils/constants.dart';
import '../model/notification.dart' as model;

class NotificationService {
  static bool allowed = false, permission = false;

  static initialize() async {
    allowed = SecureStorage().readKey(key: notificationEnabled) == 'true';
    debugPrint('>> notification allowed: $permission');

    if (!allowed) {
      permission =
          await AwesomeNotifications().requestPermissionToSendNotifications();
      debugPrint('>> notification permission: $permission');
    }

    if (permission) {
      AwesomeNotifications().initialize(
          null,
          [
            NotificationChannel(
                channelGroupKey: 'network_info_channel_group',
                channelKey: 'network_info_channel',
                channelName: 'Network Info Notifications',
                channelDescription: 'Notification channel for Network Info',
                defaultColor: const Color(0xFF9D50DD),
                ledColor: Colors.white)
          ],
          channelGroups: [
            NotificationChannelGroup(
                channelGroupKey: 'network_info_channel_group',
                channelGroupName: 'Network Info group')
          ],
          debug: true);
    } else {
      debugPrint('>> notification permission not allowed');
    }

    // const AndroidInitializationSettings initializationSettingsAndroid =
    //     AndroidInitializationSettings("app_icon");
    // DarwinInitializationSettings initializationSettingsDarwin =
    //     DarwinInitializationSettings(
    //         requestSoundPermission: false,
    //         requestBadgePermission: false,
    //         requestAlertPermission: false,
    //         onDidReceiveLocalNotification: (id, title, body, payload) {});
    //
    // InitializationSettings initializationSettings = InitializationSettings(
    //     android: initializationSettingsAndroid,
    //     iOS: initializationSettingsDarwin);
    // await flutterLocalNotificationsPlugin.initialize(
    //   initializationSettings,
    //   onDidReceiveNotificationResponse:
    //       (NotificationResponse notificationResponse) async {},
    // );
    SecureStorage()
        .writeKey(key: notificationPerm, value: permission.toString());
    SecureStorage()
        .writeKey(key: notificationEnabled, value: allowed.toString());
  }

  static Future display(
      {required model.NotificationModel notificationModel}) async {
    try {
      allowed = await AwesomeNotifications().isNotificationAllowed();

      if (allowed) {
        AwesomeNotifications().createNotification(
            content: NotificationContent(
          id: 10,
          channelKey: 'network_info_channel',
          autoDismissible: false,
          locked: true,
          displayOnForeground: true,
          actionType: ActionType.KeepOnTop,
          title: 'Network Info',
          body: notificationModel.body,
        ));
      }
    } catch (e) {
      debugPrint('>> error on showing notification: $e');
    }
  }

  static Future close() async {
    try {
      AwesomeNotifications().cancelAll();
    } catch (e) {
      debugPrint('>> error on cancelling notification: $e');
    }
  }
}
