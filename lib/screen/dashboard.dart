import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:network_info/controller/app_controller.dart';
import 'package:network_info/controller/notification_handler.dart';
import 'package:network_info/screen/history.dart';
import '../model/notification.dart' as model;
import '../utils/background_bubbles.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AppController appController = Get.put(AppController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    appController.initializeBackgroundService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Info'),
        actions: [
          IconButton(
              onPressed: () => Get.to(() => const HistoryScreen()),
              icon: const Icon(Icons.settings))
        ],
      ),
      floatingActionButton: IconButton(
        onPressed: () {
          appController.initializeBackgroundService();
        },
        icon: const Icon(Icons.refresh),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            const BGBubbles(
              hasOpacity: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => (appController.backgroundState.value)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Realtime Download Speed Data',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                  'Download Rate: ${appController.currentSpeed}'),
                              const SizedBox(
                                height: 20.0,
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Network Information',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(appController.searchingISP.value
                                  ? 'Selecting Server...'
                                  : 'IP: ${appController.dailyStat.value.ip}\nASP: ${appController.dailyStat.value.asn}\nISP: ${appController.dailyStat.value.isp}'),
                            ),
                            if (appController.searchingISP.value)
                              const CircularProgressIndicator(
                                strokeWidth: 2,
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Obx(
                    () => Stack(
                      children: [
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade400,
                                  blurRadius: 4,
                                  offset: const Offset(4, 8), // Shadow position
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 130,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Download Speed',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                      'Progress: ${appController.downloadProgress}%'),
                                  Text(
                                      'Download Rate: ${appController.dailyStat.value.downSpeed} Mbps'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 260,
                                width: 260,
                                child: CircularProgressIndicator(
                                  color: (appController.testingDownload.value)
                                      ? Colors.green
                                      : (appController.testingCompleted.value)
                                          ? Colors.deepPurple.shade100
                                          : Colors.green,
                                  backgroundColor: Colors.transparent,
                                  value: double.parse(appController
                                          .downloadProgress.value) /
                                      100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Obx(
                    () => Stack(
                      children: [
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade400,
                                  blurRadius: 4,
                                  offset: const Offset(4, 8), // Shadow position
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 130,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Upload Speed',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                      'Progress: ${appController.uploadProgress}%'),
                                  Text(
                                      'Upload Rate: ${appController.dailyStat.value.upSpeed} Mbps'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 260,
                                width: 260,
                                child: CircularProgressIndicator(
                                  color: (appController.testingUpload.value)
                                      ? Colors.green
                                      : (appController.testingCompleted.value)
                                          ? Colors.deepPurple.shade100
                                          : Colors.green,
                                  backgroundColor: Colors.transparent,
                                  value: double.parse(
                                          appController.uploadProgress.value) /
                                      100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: () async {
                  //     debugPrint('>> sendin notifi');
                  //     model.NotificationModel notificationModel =
                  //         model.NotificationModel(
                  //             title: 'Network Info',
                  //             body: 'Download Rate: 100',
                  //             payload: '100');
                  //     NotificationService.display(
                  //         notificationModel: notificationModel);
                  //   },
                  //   child: Container(
                  //       height: 50,
                  //       width: 120,
                  //       decoration: const BoxDecoration(
                  //         color: Colors.deepPurple,
                  //       ),
                  //       child: const Center(
                  //         child: Text(
                  //           'TEST',
                  //           style: TextStyle(color: Colors.white),
                  //         ),
                  //       )),
                  // )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: GestureDetector(
          onTap: () async => (!appController.testing.value &&
                  !appController.searchingISP.value)
              ? appController.getNetworkInfo()
              : {},
          child: Obx(
            () => Container(
                height: 50,
                width: 120,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: Center(
                  child: (appController.searchingISP.value ||
                          appController.testing.value)
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      : const Text(
                          'TEST',
                          style: TextStyle(color: Colors.white),
                        ),
                )),
          )),
    );
  }
}
