import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_info/screen/dashboard.dart';
import 'controller/notification_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    NotificationService.initialize();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Network Info',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
