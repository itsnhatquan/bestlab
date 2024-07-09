import 'dart:ui';

import 'package:bestlab/pages/user_setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/userList_page.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserSetting(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

