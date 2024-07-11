import 'dart:ui';

import 'package:bestlab/pages/device_list_page.dart';
import 'package:bestlab/pages/system_list_page.dart';
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SystemList(
        systems: [
          'Device 1',
          'Device 2',
          'Device 3',
          'Device 4',
          'Device 5',
          'Device 6',
          'Device 7',
          'Device 8',
          'Device 9',
          'Device 10',
        ],
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

