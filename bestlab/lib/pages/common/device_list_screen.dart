// lib/device_list_screen.dart
import 'package:bestlab/pages/api/database_service.dart';
import 'package:flutter/material.dart';

import 'webview_screen.dart';

class DeviceListScreen extends StatefulWidget {
  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  late DatabaseService _databaseService;
  late Future<List<Map<String, dynamic>>> _devices;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _devices = _fetchDevices();
  }

  Future<List<Map<String, dynamic>>> _fetchDevices() async {
    await _databaseService.connect();
    return await _databaseService.getDevices();
  }

  @override
  void dispose() {
    _databaseService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _devices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No devices found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final device = snapshot.data![index];
                return ListTile(
                  title: Text(device['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebViewScreen(url: device['url']),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'models/system.dart';
// import 'webview_screen.dart';

// class DeviceListScreen extends StatelessWidget {
//   final System system;

//   DeviceListScreen({required this.system});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(system.name),
//       ),
//       body: ListView.builder(
//         itemCount: system.devices.length,
//         itemBuilder: (context, index) {
//           final device = system.devices[index];
//           return ListTile(
//             title: Text(device.name),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => WebViewScreen(url: device.url),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }