import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:get/get.dart';
import 'package:internet_speed_meter/internet_speed_meter.dart';
import 'package:network_info/controller/secure_storage_controller.dart';
import 'package:network_info/model/info_stat.dart';
import 'package:network_info/model/notification.dart';
import 'package:network_info/utils/constants.dart';
import 'package:usage_stats/usage_stats.dart';
import 'notification_handler.dart';

class AppController extends GetxController {
  FlutterBackgroundService flutterBackgroundService =
      FlutterBackgroundService();
  FlutterBackgroundAndroidConfig androidConfig =
      const FlutterBackgroundAndroidConfig(
    notificationTitle: "Network Info app",
    notificationText: "Network Info app is running in the background",
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon: AndroidResource(
        name: 'background_icon',
        defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );

  InternetSpeedMeter internetSpeedMeterPlugin = InternetSpeedMeter();
  FlutterInternetSpeedTest internetSpeedTest = FlutterInternetSpeedTest();

  RxBool testing = false.obs,
      testingCompleted = false.obs,
      testingDownload = false.obs,
      testingUpload = false.obs,
      searchingISP = false.obs,
      fetchingUsageData = true.obs,
      backgroundState = false.obs;
  RxString downloadProgress = '0'.obs,
      uploadProgress = '0'.obs,
      currentSpeed = '0'.obs;
  RxInt historyDays = 5.obs;
  Rx<TextEditingController> historyDay = TextEditingController().obs;

  Rx<InfoStat> dailyStat = InfoStat(date: DateTime.now()).obs;

  RxList<UsageInfo> netUsageStats = <UsageInfo>[].obs;
  RxMap<DateTime, List<UsageInfo>> networkUsageStatMap =
      <DateTime, List<UsageInfo>>{}.obs;
  RxList<NetworkInfo> networkInfos = <NetworkInfo>[].obs;
  RxMap<DateTime, List<NetworkInfo>> networkInfosMap =
      <DateTime, List<NetworkInfo>>{}.obs;
  late StreamSubscription<String> speedCheck;

  Future getNetworkInfo() async {
    reset();
    await internetSpeedTest.startTesting(onStarted: () {
      testing(true);
    }, onCompleted: (TestResult download, TestResult upload) {
      dailyStat.value.downSpeed = download.transferRate;
      dailyStat.value.unit = download.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
      downloadProgress.value = '100';
      dailyStat.value.upSpeed = upload.transferRate;
      dailyStat.value.unit = upload.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
      uploadProgress.value = '100';
      testing(false);
      testingCompleted(true);
    }, onProgress: (double percent, TestResult data) {
      dailyStat.value.unit = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
      testingCompleted(false);
      if (data.type == TestType.download) {
        testingDownload(true);
        dailyStat.value.downSpeed = data.transferRate;
        downloadProgress.value = percent.toStringAsFixed(2);
      } else {
        testingUpload(true);
        dailyStat.value.upSpeed = data.transferRate;
        uploadProgress.value = percent.toStringAsFixed(2);
      }
    }, onError: (String errorMessage, String speedTestError) {
      reset();
    }, onDefaultServerSelectionInProgress: () {
      searchingISP(true);
      testingDownload(false);
      testingUpload(false);
    }, onDefaultServerSelectionDone: (Client? client) {
      searchingISP(false);
      dailyStat.value.ip = client?.ip ?? '';
      dailyStat.value.asn = client?.asn ?? 'N/A';
      dailyStat.value.isp = client?.isp ?? 'N/A';
    }, onDownloadComplete: (TestResult data) {
      dailyStat.value.downSpeed = data.transferRate;
      dailyStat.value.unit = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
      testingDownload(false);
    }, onUploadComplete: (TestResult data) {
      dailyStat.value.upSpeed = data.transferRate;
      dailyStat.value.unit = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
      testingUpload(false);
    }, onCancel: () {
      reset();
    });
  }

  // for history
  Future networkUsageStat({int? startDay}) async {
    try {
      debugPrint('>> checking network usage permission');
      UsageStats.grantUsagePermission(); // network usage log permission

      if (networkInfosMap.isEmpty || startDay != null) {
        fetchingUsageData(true);
        historyDays(startDay);
        // debugPrint('>> day count: ${startDay}');
        networkInfosMap.clear();
        for (var i = 0; i < historyDays.value; i++) {
          DateTime startDate = DateTime.now().subtract(Duration(days: i));

          List<NetworkInfo> networkInfo =
              await UsageStats.queryNetworkUsageStats(
            startDate,
            startDate.subtract(const Duration(days: 1)),
            networkType: NetworkType.wifi,
          );
          for (var i in networkInfo) {
            if (networkInfosMap.keys.contains(
                DateTime(startDate.year, startDate.month, startDate.day))) {
              networkInfosMap[
                      DateTime(startDate.year, startDate.month, startDate.day)]!
                  .add(i);
            } else {
              networkInfosMap[DateTime(
                  startDate.year, startDate.month, startDate.day)] = [i];
            }
          }
          for (var stat in networkInfosMap.entries) {
            stat.value
                .sort((a, b) => a.rxTotalBytes!.compareTo(b.rxTotalBytes!));
          }
          networkInfosMap.value = Map<DateTime, List<NetworkInfo>>.fromEntries(
              networkInfosMap.entries.toList()
                ..sort((e1, e2) => e2.key.compareTo(e1.key)));
        }
      }
    } catch (err) {
      debugPrint('>> error getting network usage stats: $err');
    } finally {
      fetchingUsageData(false);
    }
  }

  // clear current network detail
  reset() async {
    testing(false);
    searchingISP(false);
    testingDownload(false);
    testingUpload(false);
    dailyStat.value.downSpeed = 0;
    dailyStat.value.upSpeed = 0;
    downloadProgress('0');
    uploadProgress('0');
    dailyStat.value.unit = 'Mbps';
    dailyStat.value.ip = '';
    dailyStat.value.asn = 'N/A';
    dailyStat.value.isp = 'N/A';
  }

  // continuous speed data
  initializeBackgroundService() async {
    try {
      if (SecureStorage().readKey(key: backgroundPerm) != 'true') {
        // back ground running permissions
        await getBackgroundPermission().then((hasPermissions) async {
          if (hasPermissions) {
            await flutterBackgroundService.configure(
              androidConfiguration: AndroidConfiguration(
                onStart: speedText(),
                autoStart: true,
                autoStartOnBoot: true,
                isForegroundMode: true,
              ),
              iosConfiguration: IosConfiguration(
                autoStart: true,
                onForeground: speedText(),
                onBackground: speedText(),
              ),
            );

            startBackgroundService();
          } else {
            debugPrint('>> does not have permission!!!');
          }
        });
      } else {
        await flutterBackgroundService.configure(
          androidConfiguration: AndroidConfiguration(
            onStart: speedText(),
            autoStart: true,
            autoStartOnBoot: true,
            isForegroundMode: true,
          ),
          iosConfiguration: IosConfiguration(
            autoStart: true,
            onForeground: speedText(),
            onBackground: speedText(),
          ),
        );

        startBackgroundService();
      }
    } on PlatformException {
      // disable background service
      // await FlutterBackground.disableBackgroundExecution();
      currentSpeed.value = 'Failed to get currentSpeed.';
    } catch (e) {
      debugPrint('>> error here: ${e.toString()}');
      // await FlutterBackground.disableBackgroundExecution();
    }
  }

  void startBackgroundService() {
    if (!backgroundState.value) {
      if (SecureStorage().readKey(key: backgroundPerm) != 'true') {
        initializeBackgroundService();
      } else {
        flutterBackgroundService.startService();
      }
      SecureStorage().writeKey(key: backgroundEnabled, value: true.toString());
      backgroundState(true);
    }
  }

  void stopBackgroundService() {
    if (backgroundState.value) {
      if (SecureStorage().readKey(key: backgroundPerm) == 'true') {
        flutterBackgroundService.invoke("stop");
      }
      speedCheck.cancel();
      NotificationService.close();
      SecureStorage().clear(key: backgroundEnabled);
      backgroundState(false);
    }
  }

  Future<bool> getBackgroundPermission() async {
    debugPrint('>> checking background service permission');
    bool perm = await FlutterBackground
        .hasPermissions; // back ground services permission

    SecureStorage().writeKey(key: backgroundPerm, value: perm.toString());
    if (perm) {
      return perm;
    } else {
      debugPrint('>> initializing background service permission');
      bool state =
          await FlutterBackground.initialize(androidConfig: androidConfig);
      debugPrint('>> background service permission: $state');
      return state;
    }
  }

  speedText() {
    debugPrint('>> listener for network speed value changes');
    speedCheck =
        internetSpeedMeterPlugin.getCurrentInternetSpeed().listen((event) {
      currentSpeed(event);
      if (!backgroundState.value) {
        speedCheck.cancel();
      } else {
        // debugPrint('>> speed: ${currentSpeed.value}');
        NotificationModel notificationModel = NotificationModel(
            title: 'Network Info',
            body: 'Download Rate: $event',
            payload: event);
        NotificationService.display(notificationModel: notificationModel);
      }
    });
  }
}
