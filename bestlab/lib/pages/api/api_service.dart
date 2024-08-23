// services/api_service.dart

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'models/system.dart';

// class ApiService {
//   final String baseUrl;

//   ApiService({required this.baseUrl});

//   Future<List<System>> fetchSystems() async {
//     final response = await http.get(Uri.parse('$baseUrl'));

//     if (response.statusCode == 200) {
//       List<dynamic> systemsJson = json.decode(response.body);
//       return systemsJson.map((json) => System.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load systems');
//     }
//   }

//   // Add more methods here for other API calls (e.g., fetching devices, etc.)
// }