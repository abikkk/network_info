import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:internet_speed_meter/internet_speed_meter.dart';
import 'package:network_info/model/info_stat.dart';
import 'package:network_info/model/network_usage.dart';
import 'package:network_info/model/notification.dart';
import 'package:network_info/utils/constants.dart';
import 'notification_handler.dart';
import 'package:network_usage/network_usage_method_channel.dart';
import 'package:network_usage/src/model/ios_network_usage_model.dart';
import 'package:network_usage/src/model/network_usage_model.dart';

class AppController extends GetxController {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
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

  Rx<InfoStat> dailyStat = InfoStat(
          networkUsage: NetworkUsage(
              dateKey:
                  DateUtils.dateOnly(DateTime.now()).microsecondsSinceEpoch,
              wifiDownload: 0.0,
              wifiUpload: 0.0))
      .obs;
  RxList<NetworkUsage> netStat = <NetworkUsage>[].obs;
  Rx<NetworkUsage> todayStat = NetworkUsage(
          dateKey: DateUtils.dateOnly(DateTime.now()).microsecondsSinceEpoch,
          wifiDownload: 0.0,
          wifiUpload: 0.0)
      .obs;

  late StreamSubscription<String> speedCheck;

  List<NetworkUsageModel> androidDataUsage = [];
  IOSNetworkUsageModel iosDataUsage = IOSNetworkUsageModel();

  // Future getNetworkInfo() async {
  //   reset();
  //   await internetSpeedTest.startTesting(onStarted: () {
  //     testing(true);
  //   }, onCompleted: (TestResult download, TestResult upload) {
  //     dailyStat.value.networkUsage.wifiDownload = download.transferRate;
  //     dailyStat.value.unit = download.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
  //     downloadProgress.value = '100';
  //     dailyStat.value.networkUsage.wifiUpload = upload.transferRate;
  //     dailyStat.value.unit = upload.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
  //     uploadProgress.value = '100';
  //     testing(false);
  //     testingCompleted(true);
  //   }, onProgress: (double percent, TestResult data) {
  //     dailyStat.value.unit = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
  //     testingCompleted(false);
  //     if (data.type == TestType.download) {
  //       testingDownload(true);
  //       dailyStat.value.networkUsage.wifiDownload = data.transferRate;
  //       downloadProgress.value = percent.toStringAsFixed(2);
  //     } else {
  //       testingUpload(true);
  //       dailyStat.value.networkUsage.wifiUpload = data.transferRate;
  //       uploadProgress.value = percent.toStringAsFixed(2);
  //     }
  //   }, onError: (String errorMessage, String speedTestError) {
  //     reset();
  //   }, onDefaultServerSelectionInProgress: () {
  //     searchingISP(true);
  //     testingDownload(false);
  //     testingUpload(false);
  //   }, onDefaultServerSelectionDone: (Client? client) {
  //     searchingISP(false);
  //     dailyStat.value.ip = client?.ip ?? '';
  //     dailyStat.value.asn = client?.asn ?? 'N/A';
  //     dailyStat.value.isp = client?.isp ?? 'N/A';
  //   }, onDownloadComplete: (TestResult data) {
  //     dailyStat.value.networkUsage.wifiDownload = data.transferRate;
  //     dailyStat.value.unit = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
  //     testingDownload(false);
  //   }, onUploadComplete: (TestResult data) {
  //     dailyStat.value.networkUsage.wifiUpload = data.transferRate;
  //     dailyStat.value.unit = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
  //     testingUpload(false);
  //   }, onCancel: () {
  //     reset();
  //   });
  // }

  // get network usage for device
  Future getNetworkUsage() async {
    await MethodChannelNetworkUsage.init();

    if (Platform.isAndroid) {
      List<NetworkUsageModel> networkUsage;
      try {
        debugPrint('''AndroidNetworkUsage''');

        networkUsage = await MethodChannelNetworkUsage.networkUsageAndroid(
          withAppIcon: true,
          dataUsageType: NetworkUsageType.wifi,
        );

        // debugPrint(networkUsage);
        androidDataUsage = networkUsage;
      } catch (e) {
        debugPrint(e.toString());
      }
    } else if (Platform.isIOS) {
      IOSNetworkUsageModel networkIOSUsage;
      try {
        debugPrint('''IOSNetworkUsage''');

        networkIOSUsage = await MethodChannelNetworkUsage.networkUsageIOS();

        // debugPrint(networkIOSUsage);
        iosDataUsage = networkIOSUsage;
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  // background permission
  Future<bool> getBackgroundPermission() async {
    debugPrint('>> checking background service permission');
    bool perm = await FlutterBackground
        .hasPermissions; // back ground services permission

    storage.write(key: backgroundPerm, value: perm.toString());
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

  // setup background service
  initializeBackgroundService({bool restart = false}) async {
    try {
      if ((await storage.read(key: backgroundPerm)).toString() != 'true') {
        // back ground running permissions
        await getBackgroundPermission().then((hasPermissions) async {
          if (hasPermissions) {
            await flutterBackgroundService.configure(
              androidConfiguration: AndroidConfiguration(
                onStart: speedTest(),
                autoStart: true,
                autoStartOnBoot: true,
                isForegroundMode: true,
              ),
              iosConfiguration: IosConfiguration(
                autoStart: true,
                onForeground: speedTest(),
                onBackground: speedTest(),
              ),
            );
            if (restart) startBackgroundService();
          } else {
            debugPrint('>> does not have permission!!!');
          }
        });
      } else {
        await flutterBackgroundService.configure(
          androidConfiguration: AndroidConfiguration(
            onStart: speedTest(),
            autoStart: true,
            autoStartOnBoot: true,
            isForegroundMode: true,
          ),
          iosConfiguration: IosConfiguration(
            autoStart: true,
            onForeground: speedTest(),
            onBackground: speedTest(),
          ),
        );

        if (restart) startBackgroundService();
      }
    } on PlatformException {
      currentSpeed.value = 'Failed to get currentSpeed.';
    } catch (e) {
      debugPrint('>> error here: ${e.toString()}');
    }
  }

  // for history
  Future networkUsageStat() async {
    try {
      fetchingUsageData(true);

      for (var i = 0; i < 30; i++) {
        int key = DateUtils.dateOnly(DateTime.now().subtract(Duration(days: i)))
            .microsecondsSinceEpoch;

        if (await storage.read(key: key.toString()) != null) {
          NetworkUsage temp = NetworkUsage.deserialize(
              (await storage.read(key: key.toString()))!);
          if (i == 0) {
            todayStat(temp);
          }

          netStat.add(temp);

          if (i == 30) {
            storage.delete(key: netStat.last.dateKey.toString());
          }
        }
      }
    } catch (err) {
      debugPrint('>> error getting network usage stats: $err');
    } finally {
      fetchingUsageData(false);
    }
  }

  // start background service
  Future<void> startBackgroundService() async {
    if (!backgroundState.value) {
      if (await flutterBackgroundService.isRunning()) {
        debugPrint('>> background service already present');
      } else {
        flutterBackgroundService.startService();
      }
      speedTest();
      storage.write(key: backgroundEnabled, value: true.toString());
      backgroundState(true);
    }
  }

  // stop background service
  Future<void> stopBackgroundService() async {
    if (backgroundState.value) {
      if ((await storage.read(key: backgroundPerm)).toString() == 'true') {
        debugPrint('>> closing background service');
        flutterBackgroundService.invoke("stop");

        speedCheck.cancel();
        NotificationService.close();
        storage.delete(key: backgroundEnabled);
        backgroundState(false);
      }
    }
  }

  // continuous speed data
  speedTest() {
    debugPrint('>> listener for network speed value changes');
    speedCheck =
        internetSpeedMeterPlugin.getCurrentInternetSpeed().listen((event) {
      currentSpeed(event);
      if (backgroundState.value) {
        // speedCheck.cancel();
        // } else {
        // debugPrint('>> speed: ${currentSpeed.value}');
        NotificationModel notificationModel = NotificationModel(
            title: 'Network Info',
            body: 'Download Rate: $event',
            payload: event);
        NotificationService.display(notificationModel: notificationModel);
      }
      saveStats();
    });
  }

  saveStats() async {
    // bool downloadInMB = true, uploadInMB = true;

    await internetSpeedTest.startTesting(
        onCompleted: (TestResult download, TestResult upload) {
      dailyStat.value.unit = SpeedUnit.kbps.toString();
      dailyStat.value.unit = SpeedUnit.kbps.toString();

      // dailyStat.value.unit = download.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
      dailyStat.value.networkUsage.wifiDownload =
          download.unit == SpeedUnit.mbps
              ? download.transferRate
              : download.transferRate / 1000;

      // dailyStat.value.unit = upload.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
      dailyStat.value.networkUsage.wifiUpload = upload.unit == SpeedUnit.mbps
          ? upload.transferRate
          : upload.transferRate / 1000;

      // downloadInMB = download.unit == SpeedUnit.mbps;
      // uploadInMB = upload.unit == SpeedUnit.mbps;
    }).catchError((onError) {
      debugPrint(onError.toString());
    });

    int key = DateUtils.dateOnly(DateTime.now()).microsecondsSinceEpoch;

    NetworkUsage networkUsage = NetworkUsage(
        dateKey: key,
        wifiDownload: dailyStat.value.networkUsage.wifiDownload,
        wifiUpload: dailyStat.value.networkUsage.wifiUpload);

    todayStat.value.wifiDownload += networkUsage.wifiDownload;
    todayStat.value.wifiUpload += networkUsage.wifiUpload;

    await storage.write(
        key: key.toString(), value: NetworkUsage.serialize(todayStat.value));

    debugPrint(
        '>> saving speed data || ${todayStat.value.wifiDownload} ${todayStat.value.wifiUpload}');

    todayStat.refresh();
  }

  // clear current network detail
  reset() async {
    testing(false);
    searchingISP(false);
    testingDownload(false);
    testingUpload(false);
    dailyStat.value.networkUsage.wifiDownload = 0;
    dailyStat.value.networkUsage.wifiUpload = 0;
    dailyStat.value.networkUsage.cellularDownload = 0;
    dailyStat.value.networkUsage.cellularUpload = 0;
    downloadProgress('0');
    uploadProgress('0');
    dailyStat.value.unit = 'Mbps';
    dailyStat.value.ip = '';
    dailyStat.value.asn = 'N/A';
    dailyStat.value.isp = 'N/A';
  }

  resetStats() {
    storage.deleteAll();
  }
}
