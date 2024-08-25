// login_page.dart
import 'package:flutter/material.dart';
import 'package:bestlab/components/my_button.dart';
import 'package:bestlab/components/my_textfield_stateful.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:mongo_dart/mongo_dart.dart' show where, modify; // Add this line
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

  Future<bool> updateSystem(String oldName, String newName, List<String> devices) async {
    try {
        final db = await _getDbConnection();
        final collection = db.collection('systems');

        // Build the modifier to update the system name and devices
        final modifier = modify
            .set('name', newName)
            .set('devicesCount', devices.length)
            .set('devices', devices);

        // Perform the update operation without specific write concern
        final result = await collection.update(
            where.eq('name', oldName),
            modifier,
        );

        // Debugging: Print the entire result to understand its structure
        print('Update result: $result');

        // Check for an 'ok' field in the result, which should be 1 on success
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


  Future<bool> isDeviceAvailable(String deviceName) async {
    await db.open();
    var collection = db.collection('systems');
    var system = await collection.findOne({'devices': deviceName});
    await db.close();
    return system == null;
  }


  Future<bool> updateDevice(String oldName, String newName, String newUrl, String newDeviceID) async {
    try {
      final db = await _getDbConnection();
      final collection = db.collection('devices');

      // Build the modifier to update the name, URL, and device ID
      final modifier = modify
        .set('name', newName)
        .set('url', newUrl)
        .set('deviceID', newDeviceID);

      // Find the device by its current name and apply the updates
      final result = await collection.update(
        where.eq('name', oldName),
        modifier,
      );

      // Check if the update was acknowledged
      if (result['nModified'] != null && result['nModified'] > 0) {
        return true; // Update was successful
      } else if (result['updatedExisting'] != null && result['updatedExisting']) {
        // If nModified is not available, fall back to checking if an existing document was updated
        return true;
      } else {
        return false; // No documents were modified or updatedExisting was false
      }
    } catch (e) {
      print('Error updating device: $e');
      return false; // Return false if there was an error
    } finally {
      await closeDbConnection();
    }
  }

  Future<Map<String, dynamic>?> getDeviceByID(String deviceID) async {
    try {
      await db.open();
      var collection = db.collection('devices');
      var device = await collection.findOne({'deviceID': deviceID});
      await db.close();
      return device;
    } catch (e) {
      print('Error fetching device by ID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDeviceByURL(String deviceUrl) async {
    try {
      await db.open();
      var collection = db.collection('devices');
      var device = await collection.findOne({'url': deviceUrl});
      await db.close();

      if (device != null) {
        return device;
      } else {
        print('Device with URL $deviceUrl not found.');
        return null; // Return null if the device is not found
      }
    } catch (e) {
      print('Error fetching device by URL: $e');
      return null; // Return null if there was an error
    } finally {
      await db.close(); // Ensure the database connection is closed
    }
  }

  Future<Map<String, dynamic>?> getDeviceByName(String deviceName) async {
    try {
      await db.open();
      var collection = db.collection('devices');
      var device = await collection.findOne({'name': deviceName});
      await db.close();

      if (device != null) {
        return device;
      } else {
        print('Device $deviceName not found.');
        return null; // Return null if the device is not found
      }
    } catch (e) {
      print('Error fetching device: $e');
      return null; // Return null if there was an error
    } finally {
      await db.close();
    }
  }



  Future<void> addDevice(String deviceName, String deviceUrl, String deviceID) async {
    try {
      await db.open();
      var collection = db.collection('devices');

      var existingDevice = await collection.findOne({'deviceID': deviceID});
      if (existingDevice == null) {
        await collection.insertOne({
          'name': deviceName,
          'url': deviceUrl,
          'deviceID': deviceID,
          'createdAt': DateTime.now().toIso8601String(),
        });
        print('Device $deviceName added to the collection.');
      } else {
        print('Device ID $deviceID already exists.');
      }
    } catch (e) {
      print('Error adding device to MongoDB: $e');
    } finally {
      await db.close();
    }
  }


  Future<List<Map<String, dynamic>>> getSystems() async {
    await db.open();
    var collection = db.collection('systems');
    var systems = await collection.find().toList();
    await db.close();

    return systems.map((system) {
      return {
        'name': system['name'].toString(),
        'devicesCount': system['devicesCount'], // Ensure this is directly accessing the field
      };
    }).toList();
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

  Future<Map<String, dynamic>?> getSystemByName(String systemName) async {
    try {
      final db = await _getDbConnection(); // Assuming _getDbConnection returns a connected MongoDB instance
      final collection = db.collection('systems');

      // Find the system by its name
      final system = await collection.findOne(mongo.where.eq('name', systemName));

      if (system != null) {
        // Return the system details as a Map
        return {
          'name': system['name'].toString(),
          'devices': List<String>.from(system['devices'] ?? []), // Ensure it's a List<String>
          'devicesCount': system['devicesCount'] ?? 0, // Provide a default if devicesCount is missing
        };
      } else {
        // Return null if the system is not found
        return null;
      }
    } catch (e) {
      print('Error retrieving system: $e');
      return null; // Return null if there's an error
    } finally {
      await closeDbConnection(); // Ensure the database connection is closed
    }
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

  Future<Map<String, dynamic>?> fetchCurrentLoggedInUser(BuildContext context) async {
    try {
      // Accessing the UserProvider to get the user data stored during login
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      Map<String, dynamic>? currentUser = userProvider.user;

      // If user data is already stored in the provider, return it
      if (currentUser != null) {
        return currentUser;
      }

      // If not found, you might want to load the user data from persistent storage
      // e.g., from SharedPreferences, SecureStorage, or directly from the database
      // Here's an example with SharedPreferences:
      /*
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString('loggedInUser');
      if (userJson != null) {
        currentUser = jsonDecode(userJson);
        userProvider.setUser(currentUser); // Set the user in UserProvider
        return currentUser;
      }
      */

      return null; // Return null if no user is logged in
    } catch (e) {
      print('Error fetching current logged-in user: $e');
      return null;
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

      // Optionally, store the user in SharedPreferences or other storage
      /*
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('loggedInUser', jsonEncode(user));
      */

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
