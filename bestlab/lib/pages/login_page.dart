import 'package:flutter/material.dart';
import 'package:bestlab/components/my_button.dart';
import 'package:bestlab/components/my_textfield.dart';
import 'package:bestlab/components/square_tile.dart';
import 'package:bestlab/components/my_textfield_stateful.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'home_page.dart';
import 'sign_up_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<bool> signIn(String username, String password) async {
    try {
      var db = await mongo.Db.create(mongoUrl);
      await db.open();
      print('Connected to the database');

      var collection = db.collection(collectionName);
      var user = await collection.findOne({'username': username});
      print('signIn: User found: $user');

      if (user != null && user['password'] == password) {
        await db.close();
        return true;
      } else {
        await db.close();
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
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

      await collection.insert({'username': username, 'password': password});
      print('signUp: New user created: {username: $username, password: $password}');
      await db.close();
      return true;
    } catch (e) {
      print('Error: $e');
      return false;
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

    bool success = await AuthService().signIn(usernameController.text, passwordController.text);

    setState(() {
      _buttonOpacity = 1.0;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
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
                      style: TextStyle(color: Colors.grey[600]),
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
            ],
          ),
        ),
      ),
    );
  }
}
