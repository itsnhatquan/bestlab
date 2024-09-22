import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  final List<Map<String, dynamic>> notifications = [
    {
      'role': 'Admin',
      'dateTime': DateTime.now().subtract(Duration(minutes: 5)),
      'info': 'Admin John created a new user: user123.',
    },
    {
      'role': 'User',
      'dateTime': DateTime.now().subtract(Duration(hours: 1)),
      'info': 'User Sarah was assigned to system: LabSystem1.',
    },
    {
      'role': 'Admin',
      'dateTime': DateTime.now().subtract(Duration(hours: 2)),
      'info': 'Admin Emily created a new device: DeviceX.',
    },
    {
      'role': 'User',
      'dateTime': DateTime.now().subtract(Duration(days: 1)),
      'info': 'User Mike updated his username to mike_the_user.',
    },
    {
      'role': 'Admin',
      'dateTime': DateTime.now().subtract(Duration(days: 3)),
      'info': 'Admin Alex assigned User Tina to system: LabSystem3.',
    },
    {
      'role': 'Admin',
      'dateTime': DateTime.now().subtract(Duration(minutes: 15)),
      'info': 'Admin David created a new device: DeviceY.',
    },
    {
      'role': 'User',
      'dateTime': DateTime.now().subtract(Duration(hours: 4)),
      'info': 'User Jane updated her password.',
    },
    {
      'role': 'Admin',
      'dateTime': DateTime.now().subtract(Duration(days: 2)),
      'info': 'Admin Emma removed User Michael from system: LabSystem2.',
    },
    {
      'role': 'User',
      'dateTime': DateTime.now().subtract(Duration(hours: 7)),
      'info': 'User Steve was assigned to system: LabSystem4.',
    },
    {
      'role': 'Admin',
      'dateTime': DateTime.now().subtract(Duration(minutes: 45)),
      'info': 'Admin Lucy created a new user: user789.',
    },
    {
      'role': 'User',
      'dateTime': DateTime.now().subtract(Duration(hours: 3)),
      'info': 'User Hannah updated her email address.',
    },
    {
      'role': 'Admin',
      'dateTime': DateTime.now().subtract(Duration(hours: 6)),
      'info': 'Admin Kevin created a new device: DeviceZ.',
    },
    {
      'role': 'Admin',
      'dateTime': DateTime.now().subtract(Duration(days: 5)),
      'info': 'Admin John updated system configuration for LabSystem1.',
    },
    {
      'role': 'User',
      'dateTime': DateTime.now().subtract(Duration(days: 1, hours: 2)),
      'info': 'User Sam changed his username to sam_w.',
    },
    {
      'role': 'Admin',
      'dateTime': DateTime.now().subtract(Duration(days: 4)),
      'info': 'Admin Olivia created a new user: user567.',
    },
    {
      'role': 'User',
      'dateTime': DateTime.now().subtract(Duration(minutes: 30)),
      'info': 'User Karen was assigned to system: LabSystem5.',
    },
    {
      'role': 'Admin',
      'dateTime': DateTime.now().subtract(Duration(days: 2, hours: 1)),
      'info': 'Admin Mark deleted device: DeviceA.',
    },
    {
      'role': 'User',
      'dateTime': DateTime.now().subtract(Duration(hours: 8)),
      'info': 'User Ben updated his profile picture.',
    },
    {
      'role': 'Admin',
      'dateTime': DateTime.now().subtract(Duration(days: 3, hours: 5)),
      'info': 'Admin Lucy assigned User Alex to system: LabSystem6.',
    },
    {
      'role': 'User',
      'dateTime': DateTime.now().subtract(Duration(hours: 9)),
      'info': 'User Emma updated her contact information.',
    },
  ];

  String formatDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
           "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: notification['role'] == 'Admin'
                  ? Colors.blue
                  : Colors.green,
              child: Text(
                notification['role'][0],
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(notification['info']),
            subtitle: Text(
              'Role: ${notification['role']} - ${formatDate(notification['dateTime'])}',
            ),
          );
        },
      ),
    );
  }
}
