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
          'user 1',
          'user 2',
          'user 3',
          'user 4',
          'user 5',
        ],
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}