import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:network_info/controller/secure_storage_controller.dart';
import 'package:network_info/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model/notification.dart' as model;

class NotificationService {
  static bool allowed = false, permission = false;
  static FlutterSecureStorage storage = const FlutterSecureStorage();

  static initialize() async {
    allowed = await AwesomeNotifications().isNotificationAllowed();
    permission =
        (await storage.read(key: notificationPerm)).toString() == 'true';

    if (!allowed) {
      await Permission.notification.request().then((value) {
        allowed = value.isGranted;
      });
    }

    debugPrint('>> notification allowed: $allowed');
    if (!permission) {
      AwesomeNotifications()
          .requestPermissionToSendNotifications()
          .then((value) {
        debugPrint('>> notification permission: $permission');
      }).catchError((e) {
        permission = false;
        debugPrint('>> notification permission(error): ${e.toString()}');
      });
      permission = true;
    }

    debugPrint('>> notification permission: $permission');
    if (permission) {
      debugPrint('>> initializing notification');
      AwesomeNotifications().initialize(
          null,
          [
            NotificationChannel(importance: NotificationImportance.Max,
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
      debugPrint('>> notification permission not permitted');
    }

    storage.write(key: notificationPerm, value: permission.toString());
    storage.write(key: notificationEnabled, value: allowed.toString());
  }

  static Future display(
      {required model.NotificationModel notificationModel}) async {
    try {
      if ((await storage.read(key: notificationEnabled)).toString() == 'true' &&
          (await storage.read(key: notificationPerm)).toString() == 'true') {
        AwesomeNotifications().createNotification(
            content: NotificationContent(
          id: 8888,
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
