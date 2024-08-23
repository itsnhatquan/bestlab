import 'package:flutter/material.dart';
import 'package:bestlab/components/my_textfield_stateful.dart';
import 'package:bestlab/components/my_button.dart';
import 'package:bestlab/components/my_dropdown.dart';  // Import the new general dropdown component

class UserSetting extends StatefulWidget {
  UserSetting({super.key});

  @override
  _UserSettingState createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  // Text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Role selection
  String? selectedRole; // Initially null to show the hint

  // Sign user in method
  void createUser(BuildContext context) {
    if (validatePassword()) {
      // Password is valid, proceed with user creation
      // Add your user creation logic here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User created successfully! Role: $selectedRole')),
      );
    }
  }

  bool validatePassword() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password.isEmpty) {
      showError('Password cannot be empty');
      return false;
    }

    if (password.length < 8) {
      showError('Password must be at least 8 characters long');
      return false;
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      showError('Password must contain at least one number');
      return false;
    }

    if (password != confirmPassword) {
      showError('Passwords do not match');
      return false;
    }

    return true;
  }

  void showError(String message) {
    print(message); // Replace this with your preferred way of showing error messages, e.g., a Snackbar or a dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Users setting',
          style: TextStyle(
            fontSize: 35.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color.fromRGBO(0, 0, 0, 1),
          iconSize: 40.0,
          onPressed: () {
            // Handle back button press
          },
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                child: Icon(
                  Icons.person,
                  size: 150,
                ),
              ),

              const SizedBox(height: 15),

              // Username textfield
              MyTextfieldStateful(
                controller: usernameController,
                hintText: 'Username',
                labelText: 'Username',
                obscureText: false,
                showEyeIcon: false,
              ),

              const SizedBox(height: 15),

              // Password textfield
              MyTextfieldStateful(
                controller: passwordController,
                hintText: 'Password',
                labelText: 'Password',
                showEyeIcon: true,
              ),

              const SizedBox(height: 15),

              // Password confirmation
              MyTextfieldStateful(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                labelText: 'Confirm Password',
                showEyeIcon: true,
              ),

              const SizedBox(height: 15),

              // Role selection dropdown using the new MyDropdown component
              MyDropdown(
                hintText: 'Select a role...',
                labelText: 'Role',
                selectedItem: selectedRole,
                items: ['Admin', 'User'],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRole = newValue;
                  });
                },
              ),

              const SizedBox(height: 30),

              // Create user button
              MyButton(
                text: 'Create new user',
                onTap: () => createUser(context),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserSetting(),
  ));
}
