import 'package:flutter/material.dart';
import 'package:bestlab/pages/dashboard.dart';

class AdminPage extends StatelessWidget {
  final Map<String, dynamic> userData; // Add this line to store user data

  AdminPage({required this.userData, super.key}); // Update constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(userData: userData), // Pass userData to the Dashboard
    );
  }
}
