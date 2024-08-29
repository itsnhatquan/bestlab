
import 'dart:ui';

import 'package:bestlab/pages/device_list_page.dart';
import 'package:bestlab/pages/system_list_page.dart';
import 'package:bestlab/pages/user_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/user_list_page.dart';


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bestlab/components/user_provider.dart';
import 'package:bestlab/pages/login_page.dart';
import 'package:bestlab/components/themeProvider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode: false)),
      ],
      child: MyApp(),
    ),
  );
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BestLab',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,

    );
  }
}
