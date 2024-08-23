import 'dart:ui';

import 'package:bestlab/pages/api_service.dart';
import 'package:bestlab/pages/cpu_usage_chart.dart';
import 'package:bestlab/pages/device_list_page.dart';
import 'package:bestlab/pages/device_list_screen.dart';
import 'package:bestlab/pages/system_list_page.dart';
import 'package:bestlab/pages/system_list_screen.dart';
import 'package:bestlab/pages/user_setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/user_list_page.dart';


import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: LoginPage(),
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//     );
//   }
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'CPU Usage Visualization',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: CpuUsageChart(),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DeviceListScreen(),
    );
  }
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Systems and Devices',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: SystemListScreen(
//         apiService: ApiService(baseUrl: 'mongodb://nguyenducdai:0Obkv5QtElG92eNp@ac-vwtniuz-shard-00-00.foxbvln.mongodb.net:27017,ac-vwtniuz-shard-00-01.foxbvln.mongodb.net:27017,ac-vwtniuz-shard-00-02.foxbvln.mongodb.net:27017/Authentication?replicaSet=atlas-4210ho-shard-0&ssl=true&authSource=admin'),
//       ),
//     );
//   }
// }