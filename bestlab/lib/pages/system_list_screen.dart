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