import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:network_info/controller/app_controller.dart';
import 'package:network_info/screen/history.dart';
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
    WidgetsFlutterBinding.ensureInitialized();
    appController.networkUsageStat();
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
          appController.resetStats();
          // appController.networkUsageStat();
          // appController.saveStats();
        },
        icon: const Icon(Icons.delete),
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
                  // realtime stats
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
                                'Download Rate: ${appController.currentSpeed}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  // realtime service toggle
                  Row(
                    children: [
                      Expanded(
                          child: Obx(
                        () => Text(
                          'Background Services: ${appController.backgroundState.value ? 'Enabled' : 'Disabled'}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      )),
                      const SizedBox(
                        width: 5,
                      ),
                      Obx(() => !appController.backgroundState.value
                          ? IconButton(
                              onPressed: () {
                                appController.startBackgroundService();
                              },
                              icon: const Icon(
                                Icons.play_arrow,
                                size: 30,
                                color: Colors.deepPurple,
                              ),
                            )
                          : IconButton(
                              onPressed: () {
                                appController.stopBackgroundService();
                              },
                              icon: const Icon(
                                Icons.pause,
                                size: 30,
                                color: Colors.deepPurple,
                              ),
                            )),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 5,
                  ),

                  // network usage history
                  Obx(
                    () => (appController.fetchingUsageData.value)
                        ? const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : (appController.netStat.isEmpty)
                            ? const Center(
                                child: Text('No network usage data!'),
                              )
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: appController.netStat.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return (index == 0)
                                      ? ListTile(
                                          title: Text(
                                            DateTime.fromMicrosecondsSinceEpoch(
                                                    appController.todayStat
                                                        .value.dateKey)
                                                .toString()
                                                .split(' ')[0],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Obx(
                                                () => Text(
                                                    'Received: ${appController.todayStat.value.wifiDownload.toStringAsFixed(2)} Mb.'),
                                              ),
                                              Obx(
                                                () => Text(
                                                    'Sent: ${appController.todayStat.value.wifiUpload.toStringAsFixed(2)} Mb.'),
                                              ),
                                            ],
                                          ),
                                        )
                                      // ? Accordion(
                                      //     disableScrolling: true,
                                      //     contentHorizontalPadding: 10,
                                      //     scaleWhenAnimating: true,
                                      //     openAndCloseAnimation: true,
                                      //     headerPadding:
                                      //         const EdgeInsets.symmetric(
                                      //             vertical: 5, horizontal: 5),
                                      //     sectionOpeningHapticFeedback:
                                      //         SectionHapticFeedback.heavy,
                                      //     sectionClosingHapticFeedback:
                                      //         SectionHapticFeedback.light,
                                      //     children: [
                                      //         AccordionSection(
                                      //           isOpen: true,
                                      //           leftIcon: const Icon(
                                      //               Icons.calendar_month,
                                      //               color: Colors.white),
                                      //           header: Text(
                                      //             DateTime.fromMicrosecondsSinceEpoch(
                                      //                     appController
                                      //                         .todayStat
                                      //                         .value
                                      //                         .dateKey)
                                      //                 .toString()
                                      //                 .split(' ')[0],
                                      //             style: const TextStyle(
                                      //                 fontWeight:
                                      //                     FontWeight.bold,
                                      //                 fontSize: 18,
                                      //                 color: Colors.white),
                                      //           ),
                                      //           contentHorizontalPadding: 40,
                                      //           contentVerticalPadding: 20,
                                      //           content: Column(
                                      //             crossAxisAlignment:
                                      //                 CrossAxisAlignment.start,
                                      //             children: [
                                      //               Obx(
                                      //                 () => Text(
                                      //                     'Received: ${appController.todayStat.value.download.toStringAsFixed(2)} Mb.'),
                                      //               ),
                                      //               Obx(
                                      //                 () => Text(
                                      //                     'Sent: ${appController.todayStat.value.upload.toStringAsFixed(2)} Mb.'),
                                      //               ),
                                      //             ],
                                      //           ),
                                      //         ),
                                      //       ])
                                      // : Accordion(
                                      //     disableScrolling: true,
                                      //     contentHorizontalPadding: 10,
                                      //     scaleWhenAnimating: true,
                                      //     openAndCloseAnimation: true,
                                      //     headerPadding:
                                      //         const EdgeInsets.symmetric(
                                      //             vertical: 5, horizontal: 5),
                                      //     sectionOpeningHapticFeedback:
                                      //         SectionHapticFeedback.heavy,
                                      //     sectionClosingHapticFeedback:
                                      //         SectionHapticFeedback.light,
                                      //     children: [
                                      //         AccordionSection(
                                      //           isOpen: false,
                                      //           leftIcon: const Icon(
                                      //               Icons.calendar_month,
                                      //               color: Colors.white),
                                      //           header: Text(
                                      //             DateTime.fromMicrosecondsSinceEpoch(
                                      //                     appController
                                      //                         .netStat[index]
                                      //                         .dateKey)
                                      //                 .toString()
                                      //                 .split(' ')[0],
                                      //             style: const TextStyle(
                                      //                 fontWeight:
                                      //                     FontWeight.bold,
                                      //                 fontSize: 18,
                                      //                 color: Colors.white),
                                      //           ),
                                      //           contentHorizontalPadding: 40,
                                      //           contentVerticalPadding: 20,
                                      //           content: Column(
                                      //             crossAxisAlignment:
                                      //                 CrossAxisAlignment.start,
                                      //             children: [
                                      //               Text(
                                      //                   'Received: ${appController.netStat[index].download} Mb.'),
                                      //               Text(
                                      //                   'Sent: ${appController.netStat[index].upload} Mb.'),
                                      //             ],
                                      //           ),
                                      //         ),
                                      //       ])
                                      : ListTile(
                                          title: Text(
                                            DateTime.fromMicrosecondsSinceEpoch(
                                                    appController
                                                        .netStat[index].dateKey)
                                                .toString()
                                                .split(' ')[0],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'Received: ${appController.netStat[index].wifiDownload} Mb.'),
                                              Text(
                                                  'Sent: ${appController.netStat[index].wifiUpload} Mb.'),
                                            ],
                                          ),
                                        );
                                },
                              ),
                  ),
                  // Obx(
                  //   () => Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       const Text(
                  //         'Network Information',
                  //         style: TextStyle(
                  //           fontSize: 16.0,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //       Row(
                  //         children: [
                  //           Expanded(
                  //             child: Text(appController.searchingISP.value
                  //                 ? 'Selecting Server...'
                  //                 : 'IP: ${appController.dailyStat.value.ip}\nASP: ${appController.dailyStat.value.asn}\nISP: ${appController.dailyStat.value.isp}'),
                  //           ),
                  //           if (appController.searchingISP.value)
                  //             const CircularProgressIndicator(
                  //               strokeWidth: 2,
                  //             )
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(
                  //   height: 20.0,
                  // ),
                  // Obx(
                  //   () => Stack(
                  //     children: [
                  //       Center(
                  //         child: Container(
                  //           decoration: BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             boxShadow: [
                  //               BoxShadow(
                  //                 color: Colors.grey.shade400,
                  //                 blurRadius: 4,
                  //                 offset: const Offset(4, 8), // Shadow position
                  //               ),
                  //             ],
                  //           ),
                  //           child: CircleAvatar(
                  //             radius: 130,
                  //             child: Column(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               crossAxisAlignment: CrossAxisAlignment.center,
                  //               children: [
                  //                 const Text(
                  //                   'Download Speed',
                  //                   style: TextStyle(
                  //                     fontSize: 18.0,
                  //                     fontWeight: FontWeight.bold,
                  //                   ),
                  //                 ),
                  //                 const SizedBox(
                  //                   height: 5,
                  //                 ),
                  //                 Text(
                  //                     'Progress: ${appController.downloadProgress}%'),
                  //                 Text(
                  //                     'Download Rate: ${appController.dailyStat.value.downSpeed} Mbps'),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       Center(
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           crossAxisAlignment: CrossAxisAlignment.center,
                  //           children: [
                  //             SizedBox(
                  //               height: 260,
                  //               width: 260,
                  //               child: CircularProgressIndicator(
                  //                 color: (appController.testingDownload.value)
                  //                     ? Colors.green
                  //                     : (appController.testingCompleted.value)
                  //                         ? Colors.deepPurple.shade100
                  //                         : Colors.green,
                  //                 backgroundColor: Colors.transparent,
                  //                 value: double.parse(appController
                  //                         .downloadProgress.value) /
                  //                     100,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(
                  //   height: 20.0,
                  // ),
                  // Obx(
                  //   () => Stack(
                  //     children: [
                  //       Center(
                  //         child: Container(
                  //           decoration: BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             boxShadow: [
                  //               BoxShadow(
                  //                 color: Colors.grey.shade400,
                  //                 blurRadius: 4,
                  //                 offset: const Offset(4, 8), // Shadow position
                  //               ),
                  //             ],
                  //           ),
                  //           child: CircleAvatar(
                  //             radius: 130,
                  //             child: Column(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               crossAxisAlignment: CrossAxisAlignment.center,
                  //               children: [
                  //                 const Text(
                  //                   'Upload Speed',
                  //                   style: TextStyle(
                  //                     fontSize: 18.0,
                  //                     fontWeight: FontWeight.bold,
                  //                   ),
                  //                 ),
                  //                 const SizedBox(
                  //                   height: 5,
                  //                 ),
                  //                 Text(
                  //                     'Progress: ${appController.uploadProgress}%'),
                  //                 Text(
                  //                     'Upload Rate: ${appController.dailyStat.value.upSpeed} Mbps'),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       Center(
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           crossAxisAlignment: CrossAxisAlignment.center,
                  //           children: [
                  //             SizedBox(
                  //               height: 260,
                  //               width: 260,
                  //               child: CircularProgressIndicator(
                  //                 color: (appController.testingUpload.value)
                  //                     ? Colors.green
                  //                     : (appController.testingCompleted.value)
                  //                         ? Colors.deepPurple.shade100
                  //                         : Colors.green,
                  //                 backgroundColor: Colors.transparent,
                  //                 value: double.parse(
                  //                         appController.uploadProgress.value) /
                  //                     100,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
              // ? appController.getNetworkInfo()
              ? {}
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
