// // lib/system_list_screen.dart
// import 'package:flutter/material.dart';
// import 'database_service.dart';
// import 'device_list_screen.dart';

// class SystemListScreen extends StatefulWidget {
//   @override
//   _SystemListScreenState createState() => _SystemListScreenState();
// }

// class _SystemListScreenState extends State<SystemListScreen> {
//   late DatabaseService _databaseService;
//   late Future<List<Map<String, dynamic>>> _systems;

//   @override
//   void initState() {
//     super.initState();
//     _databaseService = DatabaseService();
//     _systems = _fetchSystems();
//   }

//   Future<List<Map<String, dynamic>>> _fetchSystems() async {
//     await _databaseService.connect();
//     return await _databaseService.getSystems(); // Implement getSystems() in DatabaseService
//   }

//   @override
//   void dispose() {
//     _databaseService.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('System List'),
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _systems,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No systems found'));
//           } else {
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 final system = snapshot.data![index];
//                 return ListTile(
//                   title: Text(system['name']),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => DeviceListScreen(systemId: system['_id'].toString()),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'models/system.dart';
// import 'api_service.dart';
// import 'device_list_screen.dart';

// class SystemListScreen extends StatelessWidget {
//   final ApiService apiService;

//   SystemListScreen({required this.apiService});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Systems'),
//       ),
//       body: FutureBuilder<List<System>>(
//         future: apiService.fetchSystems(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 final system = snapshot.data![index];
//                 return ListTile(
//                   title: Text(system.name),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => DeviceListScreen(system: system),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// import 'package:bestlab/pages/api/mongo_db_service.dart';
// import 'package:flutter/material.dart';
// import 'device_list_screenn.dart';

// class SystemListScreen extends StatefulWidget {
//   @override
//   _SystemListScreenState createState() => _SystemListScreenState();
// }

// class _SystemListScreenState extends State<SystemListScreen> {
//   final MongoDBService _mongoDBService = MongoDBService();
//   List<Map<String, dynamic>> _systems = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchSystems();
//   }

//   Future<void> _fetchSystems() async {
//     await _mongoDBService.connect();
//     final systems = await _mongoDBService.getSystems();
//     setState(() {
//       _systems = systems;
//     });
//     await _mongoDBService.close();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Systems'),
//       ),
//       body: ListView.builder(
//         itemCount: _systems.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(_systems[index]['name']),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => DeviceListScreen(systemId: _systems[index]['_id'].toString()),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:bestlab/pages/api/mongo_db_service.dart';
// import 'package:flutter/material.dart';
// import 'device_list_screenn.dart';  // Fixed the import path

// class SystemListScreen extends StatefulWidget {
//   @override
//   _SystemListScreenState createState() => _SystemListScreenState();
// }

// class _SystemListScreenState extends State<SystemListScreen> {
//   final MongoDBService _mongoDBService = MongoDBService();
//   List<Map<String, dynamic>> _systems = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchSystems();
//   }

//   Future<void> _fetchSystems() async {
//     try {
//       await _mongoDBService.connect();
//       final systems = await _mongoDBService.getSystems();
      
//       if (mounted) {
//         setState(() {
//           _systems = systems;
//         });
//       }
//     } catch (e) {
//       print('Failed to fetch systems: $e');
//     } finally {
//       await _mongoDBService.close();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Systems'),
//       ),
//       body: ListView.builder(
//         itemCount: _systems.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(_systems[index]['name']),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => DeviceListScreen(systemId: _systems[index]['_id'].toString()),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // Clean up resources if needed
//     super.dispose();
//   }
// }