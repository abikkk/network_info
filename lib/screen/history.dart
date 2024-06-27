import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_info/utils/background_bubbles.dart';
import '../controller/app_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  AppController appController = Get.find<AppController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    appController.networkUsageStat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('History'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Obx(
                      () => Text(
                        'Background Services: ${appController.backgroundState.value ? 'Enabled' : 'Disabled'}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    )),
                    IconButton(
                        onPressed: () {
                          appController.startBackgroundService();
                        },
                        icon: const Icon(
                          Icons.play_arrow,
                          size: 30,
                        )),
                    const SizedBox(
                      width: 5,
                    ),
                    IconButton(
                        onPressed: () {
                          appController.stopBackgroundService();
                        },
                        icon: const Icon(
                          Icons.pause,
                          size: 30,
                        )),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  endIndent: 10,
                  indent: 10,
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  'History of Network Usage:',
                  style: TextStyle(fontSize: 18),
                ),
                Obx(
                  () => (appController.fetchingUsageData.value)
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : (appController.networkInfosMap.isEmpty)
                          ? const Center(
                              child: Text('No network usage data!'),
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              // itemCount: 1,
                              itemCount:
                                  appController.networkInfosMap.length,
                              itemBuilder:
                                  (BuildContext context, int index) {
                                DateTime key = appController
                                    .networkInfosMap.keys
                                    .elementAt(index);
                                return Accordion(
                                    disableScrolling: true,
                                    contentHorizontalPadding: 10,
                                    scaleWhenAnimating: true,
                                    openAndCloseAnimation: true,
                                    headerPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 5),
                                    sectionOpeningHapticFeedback:
                                        SectionHapticFeedback.heavy,
                                    sectionClosingHapticFeedback:
                                        SectionHapticFeedback.light,
                                    children: [
                                      AccordionSection(
                                          isOpen: false,
                                          leftIcon: const Icon(
                                              Icons.calendar_month,
                                              color: Colors.white),
                                          header: Text(
                                            key.toString().split(' ')[0],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                          contentHorizontalPadding: 40,
                                          contentVerticalPadding: 20,
                                          content: ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: appController
                                                .networkInfosMap[key]!
                                                .length,
                                            itemBuilder:
                                                (BuildContext context,
                                                    int statIndex) {
                                              return ListTile(
                                                title: Text(appController
                                                    .networkInfosMap[key]![
                                                        statIndex]
                                                    .packageName!),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Text(
                                                        'Received: ${appController.networkInfosMap[key]![statIndex].rxTotalBytes!} bytes.'),
                                                    Text(
                                                        'Sent: ${appController.networkInfosMap[key]![statIndex].txTotalBytes!} bytes.'),
                                                  ],
                                                ),
                                                isThreeLine: true,
                                              );
                                            },
                                          )),
                                    ]);
                              },
                            ),
                ),
              ],
            ),
          ),
        ));
  }
}
