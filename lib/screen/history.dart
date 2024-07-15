import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../controller/app_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  AppController appController = Get.find<AppController>();

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
                // const Text(
                //   'History of Network Usage:',
                //   style: TextStyle(fontSize: 18),
                // ),
                // const SizedBox(
                //   height: 5,
                // ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: TextFormField(
                //         expands: false,
                //         decoration: InputDecoration(
                //             suffix: IconButton(
                //                 onPressed: () {}, icon: const Icon(Icons.done)),
                //             labelText: 'Day count for past records',
                //             hintText: '1-15'),
                //         controller: appController.historyDay.value,
                //         validator: (val) {
                //           if (val!.trim().isEmpty) {
                //             return "Please enter the number of day(s) for history!";
                //           } else if (!val.isNumericOnly) {
                //             return "Please enter a valid number!";
                //           } else if (int.parse(val) > 15) {
                //             return "Max 15 days record can be accessed!";
                //           }
                //           return null;
                //         },
                //         onFieldSubmitted: (day) {
                //           appController.networkUsageStat(
                //               startDay: int.parse(day));
                //         },
                //         keyboardType: TextInputType.number,
                //         textInputAction: TextInputAction.done,
                //         inputFormatters: [
                //           FilteringTextInputFormatter(RegExp(r'(^\d*\.?\d*)'),
                //               allow: true)
                //         ],
                //       ),
                //     )
                //   ],
                // ),
                // const SizedBox(
                //   height: 10,
                // ),
              ],
            ),
          ),
        ));
  }
}
