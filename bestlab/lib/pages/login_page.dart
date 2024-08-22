// login_page.dart
import 'package:flutter/material.dart';
import 'package:bestlab/components/my_button.dart';
import 'package:bestlab/components/my_textfield_stateful.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'sign_up_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'admin_home_page.dart';
import 'package:bestlab/components/themeProvider.dart';
import 'package:bestlab/components/user_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BestLab',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class AuthService {
  final String mongoUrl = 'mongodb+srv://nguyenducdai:0Obkv5QtElG92eNp@bestlab-prod-1.foxbvln.mongodb.net/Authentication?retryWrites=true&w=majority&appName=BESTLAB-PROD-1';
  final String dbName = 'Authentication';
  final String collectionName = 'userAuth';
  final Uuid uuid = Uuid();
  mongo.Db? _db;
  final mongo.Db db = mongo.Db('mongodb://nguyenducdai:0Obkv5QtElG92eNp@ac-vwtniuz-shard-00-00.foxbvln.mongodb.net:27017,ac-vwtniuz-shard-00-01.foxbvln.mongodb.net:27017,ac-vwtniuz-shard-00-02.foxbvln.mongodb.net:27017/Authentication?replicaSet=atlas-4210ho-shard-0&ssl=true&authSource=admin');

  Future<void> deleteSystem(String systemName) async {
    try {
      await db.open();
      var collection = db.collection('systems');
      await collection.remove({'name': systemName});
      print('System $systemName deleted successfully.');
    } catch (e) {
      print('Error deleting system: $e');
    } finally {
      await db.close();
    }
  }

  Future<void> deleteDevice(String deviceName) async {
    try {
      await db.open();
      var collection = db.collection('devices');
      await collection.remove({'name': deviceName});
      print('Device $deviceName deleted successfully.');
    } catch (e) {
      print('Error deleting device: $e');
    } finally {
      await db.close();
    }
  }
  
  Future<bool> isDeviceAvailable(String deviceName) async {
    await db.open();
    var collection = db.collection('systems');
    var system = await collection.findOne({'devices': deviceName});
    await db.close();
    return system == null;
  }

  Future<void> addDevice(String deviceName) async {
    try {
      await db.open();
      var collection = db.collection('devices');

      var existingDevice = await collection.findOne({'name': deviceName});
      if (existingDevice == null) {
        await collection.insertOne({
          'name': deviceName,
          'createdAt': DateTime.now().toIso8601String(),
        });
        print('Device $deviceName added to the collection.');
      } else {
        print('Device $deviceName already exists.');
      }
    } catch (e) {
      print('Error adding device to MongoDB: $e');
    } finally {
      await db.close();
    }
  }

  Future<List<String>> getSystems() async {
    await db.open();
    var collection = db.collection('systems');
    var systems = await collection.find().toList();
    await db.close();
    return systems.map((system) => system['name'].toString()).toList();
  }

  Future<List<String>> getAllDevices() async {
    List<String> allDevices = [];
    try {
      await db.open();
      var collection = db.collection('devices');
      var devices = await collection.find().toList();

      for (var device in devices) {
        if (device['name'] != null) {
          allDevices.add(device['name'].toString());
        }
      }
    } catch (e) {
      print('Error fetching all devices: $e');
    } finally {
      await db.close();
    }
    return allDevices;
  }

  Future<List<String>> getSystemDevices(String systemName) async {
    try {
      await db.open();
      var collection = db.collection('systems');
      var system = await collection.findOne({'name': systemName});
      await db.close();

      if (system != null && system.containsKey('devices')) {
        return List<String>.from(system['devices']);
      } else {
        return []; // Return an empty list if no devices found or system doesn't exist
      }
    } catch (e) {
      print('Error fetching devices: $e');
      return [];
    }
  }

  Future<mongo.Db> _getDbConnection() async {
    if (_db == null || _db!.state == mongo.State.CLOSED) {
      _db = mongo.Db('mongodb://nguyenducdai:0Obkv5QtElG92eNp@ac-vwtniuz-shard-00-00.foxbvln.mongodb.net:27017,ac-vwtniuz-shard-00-01.foxbvln.mongodb.net:27017,ac-vwtniuz-shard-00-02.foxbvln.mongodb.net:27017/Authentication?replicaSet=atlas-4210ho-shard-0&ssl=true&authSource=admin');
      await _db!.open();
    }
    return _db!;
  }

  Future<void> closeDbConnection() async {
    if (_db != null && _db!.state == mongo.State.OPEN) {
      await _db!.close();
    }
  }

  Future<String?> getUserRole(String username) async {
    try {
      final db = await _getDbConnection();
      var collection = db.collection(collectionName);
      var user = await collection.findOne({'username': username});
      
      if (user != null) {
        return user['systemRole'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    } finally {
      await closeDbConnection();
    }
  }

  Future<Map<String, dynamic>?> signIn(String username, String password) async {
    try {
      await db.open();
      print('Connected to the database');

      var collection = db.collection(collectionName);
      var user = await collection.findOne({'username': username});
      print('signIn: User found: $user');

      if (user != null && user['password'] == password) {
        await db.close();
        return user; // Return the entire user document
      } else {
        await db.close();
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<bool> signUp(String username, String password) async {
    try {
      var db = await mongo.Db.create(mongoUrl);
      await db.open();
      print('Connected to the database');

      var collection = db.collection(collectionName);
      var user = await collection.findOne({'username': username});
      if (user != null) {
        print('signUp: User already exists: $user');
        await db.close();
        return false; // User already exists
      }

      await collection.insert({
        'userID': uuid.v4(), // Generate a unique userID
        'username': username,
        'password': password,
        'name': '',
        'age': 0,
        'systemRole': 'user', // Default role set to 'user'
        'systemAccess': '',
      });
      print('signUp: New user created: {username: $username, password: $password}');
      await db.close();
      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      var db = await mongo.Db.create(mongoUrl);
      await db.open();
      print('Connected to the database');

      var collection = db.collection(collectionName);
      var users = await collection.find().toList();

      await db.close();
      return users;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      var db = await mongo.Db.create(mongoUrl);
      await db.open();
      print('Connected to the database');

      var collection = db.collection(collectionName);
      await collection.remove({'userID': userId}); // Use 'userID' if you're storing UUIDs as strings

      print('deleteUser: User deleted: $userId');
      await db.close();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<bool> addUser(Map<String, dynamic> user) async {
    try {
      await db.open();
      var collection = db.collection(collectionName);
      await collection.insert(user);
      await db.close();
      return true; // Successfully added the user
    } catch (e) {
      print('Error adding user: $e');
      return false; // Failed to add the user
    } finally {
      await db.close();
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> updatedData) async {
  try {
    final db = await _getDbConnection();
    final collection = db.collection(collectionName);

    // Initialize the modifier builder
    var modifier = mongo.ModifierBuilder();

    // Add each key-value pair in updatedData to the modifier
    updatedData.forEach((key, value) {
      modifier.set(key, value);
    });

    // Perform the update
    final result = await collection.update(
      mongo.where.eq('userID', userId),
      modifier,
      multiUpdate: false, // Only update one document
      writeConcern: mongo.WriteConcern.ACKNOWLEDGED,
    );

    // Check if any documents were modified
    if (result['nModified'] != null && result['nModified'] > 0) {
      return true; // Update was successful
    } else if (result['n'] != null && result['n'] == 0) {
      // If no document was matched, consider it a failure
      return false;
    } else {
      // Document matched but not modified (no actual changes needed)
      return true;
    }
  } catch (e) {
    print('Error updating user: $e');
    return false; // Return false if there was an error
  } finally {
    await closeDbConnection();
  }
}


  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      var db = await mongo.Db.create(mongoUrl);
      await db.open();
      var collection = db.collection(collectionName);
      await collection.update(
        {'userID': userId},
        {'\$set': {'systemRole': newRole}},
      );
      await db.close();
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to update role');
    }
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  double _buttonOpacity = 1.0;

  void signUserIn(BuildContext context) async {
    setState(() {
      _buttonOpacity = 0.5;
    });

    AuthService authService = AuthService();
    var user = await authService.signIn(usernameController.text, passwordController.text);

    setState(() {
      _buttonOpacity = 1.0;
    });

    if (user != null) {
      String role = user['systemRole'];

      // Store the user globally using UserProvider
      Provider.of<UserProvider>(context, listen: false).setUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Successful!')),
      );

      if (role.toLowerCase() == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPage(userData: user),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userData: user)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Access the theme provider

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset('lib/images/logo.png', height: 293),
                const SizedBox(height: 50),
                MyTextfieldStateful(
                  controller: usernameController,
                  hintText: 'Username',
                  labelText: 'Username',
                  obscureText: false,
                  showEyeIcon: false,
                ),
                const SizedBox(height: 10),
                MyTextfieldStateful(
                  controller: passwordController,
                  hintText: 'Password',
                  labelText: 'Password',
                  showEyeIcon: true,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                AnimatedOpacity(
                  opacity: _buttonOpacity,
                  duration: Duration(milliseconds: 300),
                  child: MyButton(
                    text: 'Sign In',
                    onTap: () => signUserIn(context),
                  ),
                ),
                const SizedBox(height: 50),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text('Not a member? Register now'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
