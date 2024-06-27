import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        expands: false,
                        decoration: InputDecoration(
                            suffix: IconButton(
                                onPressed: () {}, icon: const Icon(Icons.done)),
                            labelText: 'Day count for past records',
                            hintText: '1-15'),
                        controller: appController.historyDay.value,
                        validator: (val) {
                          if (val!.trim().isEmpty) {
                            return "Please enter the number of day(s) for history!";
                          } else if (!val.isNumericOnly) {
                            return "Please enter a valid number!";
                          } else if (int.parse(val) > 15) {
                            return "Max 15 days record can be accessed!";
                          }
                          return null;
                        },
                        onFieldSubmitted: (day) {
                          appController.networkUsageStat(
                              startDay: int.parse(day));
                        },
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter(RegExp(r'(^\d*\.?\d*)'),
                              allow: true)
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
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
                              itemCount: appController.networkInfosMap.length,
                              itemBuilder: (BuildContext context, int index) {
                                DateTime key = appController
                                    .networkInfosMap.keys
                                    .elementAt(index);
                                return Accordion(
                                    disableScrolling: true,
                                    contentHorizontalPadding: 10,
                                    scaleWhenAnimating: true,
                                    openAndCloseAnimation: true,
                                    headerPadding: const EdgeInsets.symmetric(
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
                                                .networkInfosMap[key]!.length,
                                            itemBuilder: (BuildContext context,
                                                int statIndex) {
                                              return ListTile(
                                                title: Text(appController
                                                    .networkInfosMap[key]![
                                                        statIndex]
                                                    .packageName!),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
