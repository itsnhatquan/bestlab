// import 'package:flutter/material.dart';
//
// class HomePage extends StatelessWidget {
//   HomePage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'App Name',
//           style: TextStyle(
//             fontSize: 35.0,
//             fontWeight: FontWeight.bold,
//           )
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.person),
//           color: Color.fromRGBO(68, 107, 186, 1),
//           iconSize: 40.0,
//           padding: EdgeInsets.fromLTRB(70, 0, 0, 0),
//           onPressed: () {
//             // Add your onPressed code here!
//           },
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 HomeCard(
//                   icon: Icons.person,
//                   text: 'User',
//                   onTap: () {
//                     // Add your onTap code here!
//                   },
//                 ),
//                 HomeCard(
//                   icon: Icons.description,
//                   text: 'Template',
//                   onTap: () {
//                     // Add your onTap code here!
//                   },
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 HomeCard(
//                   icon: Icons.computer,
//                   text: 'System',
//                   onTap: () {
//                     // Add your onTap code here!
//                   },
//                 ),
//                 HomeCard(
//                   icon: Icons.settings,
//                   text: 'Settings',
//                   onTap: () {
//                     // Add your onTap code here!
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class HomeCard extends StatelessWidget {
//   final IconData icon;
//   final String text;
//   final Function onTap;
//
//   HomeCard({required this.icon, required this.text, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => onTap(),
//       child: Container(
//         width: 150,
//         height: 150,
//         decoration: BoxDecoration(
//           color: Color.fromRGBO(75, 117, 198, 1),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Color.fromRGBO(20, 60, 155, 1),
//               spreadRadius: 1,
//               blurRadius: 1,
//               offset: Offset(0, 0), // changes position of shadow
//             ),
//           ],
//           border: Border.all(
//             color: Color.fromRGBO(20, 60, 155, 1),
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 50,
//               color: Colors.white,
//             ),
//             SizedBox(height: 10),
//             Text(
//               text,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'login_page.dart';

// class HomePage extends StatelessWidget {
//   HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'App Name',
//           style: TextStyle(
//             fontSize: 35.0,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.person),
//           color: Color.fromRGBO(68, 107, 186, 1),
//           iconSize: 40.0,
//           padding: EdgeInsets.fromLTRB(70, 0, 0, 0),
//           onPressed: () {
//             // Add your onPressed code here!
//           },
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () async {
//               bool? confirmLogout = await showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: Text('Confirm Logout'),
//                   content: Text('Are you sure you want to log out?'),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.of(context).pop(false),
//                       child: Text('Cancel'),
//                     ),
//                     TextButton(
//                       onPressed: () => Navigator.of(context).pop(true),
//                       child: Text('Logout'),
//                     ),
//                   ],
//                 ),
//               );

//               if (confirmLogout == true) {
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginPage()),
//                       (route) => false,
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 HomeCard(
//                   icon: Icons.person,
//                   text: 'User',
//                   onTap: () {
//                     // Add your onTap code here!
//                   },
//                 ),
//                 HomeCard(
//                   icon: Icons.description,
//                   text: 'Template',
//                   onTap: () {
//                     // Add your onTap code here!
//                   },
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 HomeCard(
//                   icon: Icons.computer,
//                   text: 'System',
//                   onTap: () {
//                     // Add your onTap code here!
//                   },
//                 ),
//                 HomeCard(
//                   icon: Icons.settings,
//                   text: 'Settings',
//                   onTap: () {
//                     // Add your onTap code here!
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class HomeCard extends StatelessWidget {
//   final IconData icon;
//   final String text;
//   final Function onTap;

//   HomeCard({required this.icon, required this.text, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => onTap(),
//       child: Container(
//         width: 150,
//         height: 150,
//         decoration: BoxDecoration(
//           color: Color.fromRGBO(75, 117, 198, 1),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Color.fromRGBO(20, 60, 155, 1),
//               spreadRadius: 1,
//               blurRadius: 1,
//               offset: Offset(0, 0), // changes position of shadow
//             ),
//           ],
//           border: Border.all(
//             color: Color.fromRGBO(20, 60, 155, 1),
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 50,
//               color: Colors.white,
//             ),
//             SizedBox(height: 10),
//             Text(
//               text,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:bestlab/pages/dashboard.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> userData; // Add this line to store user data

  HomePage({required this.userData, super.key}); // Update constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(userData: userData), // Pass userData to the Dashboard
    );
  }
}
